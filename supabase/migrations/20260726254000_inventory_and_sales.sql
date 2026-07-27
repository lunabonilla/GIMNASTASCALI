create table public.products (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  category text not null default 'other'
    check (category in ('training_leotard', 'gala_leotard', 'grips', 'wristbands', 'shirt', 'other')),
  variant text,
  sku text unique,
  sale_price_cents bigint not null check (sale_price_cents >= 0),
  cost_cents bigint check (cost_cents is null or cost_cents >= 0),
  stock_quantity integer not null default 0 check (stock_quantity >= 0),
  minimum_stock integer not null default 0 check (minimum_stock >= 0),
  active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.inventory_movements (
  id uuid primary key default gen_random_uuid(),
  product_id uuid not null references public.products(id) on delete restrict,
  movement_type text not null check (movement_type in ('initial', 'purchase', 'sale', 'adjustment', 'return')),
  quantity_change integer not null check (quantity_change <> 0),
  reason text,
  created_by uuid references public.staff_profiles(id) on delete set null,
  created_at timestamptz not null default now()
);

create table public.sales (
  id uuid primary key default gen_random_uuid(),
  gymnast_id uuid references public.gymnasts(id) on delete set null,
  customer_name text,
  sold_on date not null default current_date,
  total_cents bigint not null check (total_cents >= 0),
  payment_status text not null default 'paid'
    check (payment_status in ('paid', 'pending')),
  payment_method text check (
    payment_method is null
    or payment_method in ('cash', 'transfer', 'card', 'other')
  ),
  notes text,
  created_by uuid references public.staff_profiles(id) on delete set null,
  created_at timestamptz not null default now()
);

create table public.sale_items (
  id uuid primary key default gen_random_uuid(),
  sale_id uuid not null references public.sales(id) on delete cascade,
  product_id uuid not null references public.products(id) on delete restrict,
  quantity integer not null check (quantity > 0),
  unit_price_cents bigint not null check (unit_price_cents >= 0),
  line_total_cents bigint generated always as (quantity * unit_price_cents) stored,
  created_at timestamptz not null default now()
);

create index inventory_movements_product_idx
  on public.inventory_movements(product_id, created_at desc);

create index sales_sold_on_idx on public.sales(sold_on desc);

create trigger products_updated_at
before update on public.products
for each row execute function public.set_updated_at();

create or replace function public.adjust_product_stock(
  target_product_id uuid,
  quantity_delta integer,
  movement_reason text default null
)
returns integer
language plpgsql
security invoker
set search_path = ''
as $$
declare
  resulting_stock integer;
begin
  if not public.is_management() then
    raise exception 'No autorizado';
  end if;

  update public.products
  set stock_quantity = stock_quantity + quantity_delta
  where id = target_product_id
    and stock_quantity + quantity_delta >= 0
  returning stock_quantity into resulting_stock;

  if resulting_stock is null then
    raise exception 'La existencia no puede quedar negativa';
  end if;

  insert into public.inventory_movements (
    product_id, movement_type, quantity_change, reason, created_by
  ) values (
    target_product_id,
    case when quantity_delta > 0 then 'purchase' else 'adjustment' end,
    quantity_delta,
    movement_reason,
    auth.uid()
  );

  return resulting_stock;
end;
$$;

create or replace function public.register_product_sale(
  target_product_id uuid,
  sale_quantity integer,
  target_gymnast_id uuid default null,
  buyer_name text default null,
  sale_payment_status text default 'paid',
  sale_payment_method text default 'transfer',
  sale_notes text default null
)
returns uuid
language plpgsql
security invoker
set search_path = ''
as $$
declare
  product_price bigint;
  available_stock integer;
  new_sale_id uuid;
begin
  if not public.is_management() then
    raise exception 'No autorizado';
  end if;
  if sale_quantity <= 0 then
    raise exception 'La cantidad debe ser mayor que cero';
  end if;

  select sale_price_cents, stock_quantity
  into product_price, available_stock
  from public.products
  where id = target_product_id and active = true
  for update;

  if product_price is null or available_stock < sale_quantity then
    raise exception 'No hay existencias suficientes';
  end if;

  insert into public.sales (
    gymnast_id, customer_name, total_cents, payment_status,
    payment_method, notes, created_by
  ) values (
    target_gymnast_id, nullif(trim(buyer_name), ''),
    product_price * sale_quantity, sale_payment_status,
    case when sale_payment_status = 'paid' then sale_payment_method else null end,
    sale_notes, auth.uid()
  ) returning id into new_sale_id;

  insert into public.sale_items (
    sale_id, product_id, quantity, unit_price_cents
  ) values (
    new_sale_id, target_product_id, sale_quantity, product_price
  );

  update public.products
  set stock_quantity = stock_quantity - sale_quantity
  where id = target_product_id;

  insert into public.inventory_movements (
    product_id, movement_type, quantity_change, reason, created_by
  ) values (
    target_product_id, 'sale', -sale_quantity,
    'Venta ' || new_sale_id::text, auth.uid()
  );

  return new_sale_id;
end;
$$;

alter table public.products enable row level security;
alter table public.inventory_movements enable row level security;
alter table public.sales enable row level security;
alter table public.sale_items enable row level security;

create policy "management manages products"
on public.products for all to authenticated
using (public.is_management()) with check (public.is_management());

create policy "management manages inventory movements"
on public.inventory_movements for all to authenticated
using (public.is_management()) with check (public.is_management());

create policy "management manages sales"
on public.sales for all to authenticated
using (public.is_management()) with check (public.is_management());

create policy "management manages sale items"
on public.sale_items for all to authenticated
using (public.is_management()) with check (public.is_management());

grant select, insert, update, delete on public.products to authenticated;
grant select, insert, update, delete on public.inventory_movements to authenticated;
grant select, insert, update, delete on public.sales to authenticated;
grant select, insert, update, delete on public.sale_items to authenticated;
grant execute on function public.adjust_product_stock(uuid, integer, text) to authenticated;
grant execute on function public.register_product_sale(uuid, integer, uuid, text, text, text, text) to authenticated;
