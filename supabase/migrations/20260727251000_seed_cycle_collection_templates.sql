insert into public.communication_templates (name, channel, purpose, body)
select template.name, 'whatsapp', 'cycle_collection', template.body
from (
  values
    (
      'Recordatorio de inicio del ciclo',
      $template$Hola buenas

Te recuerdo que la niña inició su ciclo el ___ 🤸‍♀️💜

El pago se realiza dentro de los *cinco (5) días calendario posteriores a la fecha de inicio*, así que te agradezco mucho tenerlo presente para mantener el proceso al día 🙏✨

Gracias por el compromiso y apoyo de siempre.

Un abrazo 💜$template$
    ),
    (
      'Último día de pago sin recargo',
      $template$Hola buenas tardes

Te escribo porque el ciclo iniciado el ___ *ya está dentro de los cinco (5) días hábiles establecidos para el pago*

Quería contarte que *hoy sería el último día para realizar el pago sin recargo.* A partir de mañana, como parte de la organización administrativa del club, comenzará a aplicarse el recargo por pago extemporáneo.

Te agradezco mucho si me ayudas realizando el pago el día de hoy para evitar ese ajuste 🙏💜

Gracias siempre por el apoyo y la comprensión.$template$
    ),
    (
      'Ciclo vencido con recargo',
      $template$Hola

Te escribo porque el ciclo iniciado el ___ *ya superó los cinco (5) días hábiles establecidos para el pago*

Como parte de la organización del club, *a partir de este momento corresponde aplicar el recargo por pago extemporáneo.*

Te agradezco mucho si me ayudas realizando el pago lo antes posible para dejar todo al día 🙏💜

Gracias siempre por el apoyo.$template$
    ),
    (
      'Ciclo y matrícula pendientes',
      $template$Espero que estés muy bien. Quería escribirte para informarte de manera muy cordial, el pago del ciclo, teniendo en cuenta que ___ inició su proceso el día ___.

Actualmente se encuentra pendiente el pago correspondiente a:
	•	Valor del ciclo: $___
	•	Valor de matrícula: $___

       •	*Valor total: $___*

Los pagos se deben realizar dentro de los primeros cinco días desde el inicio del ciclo. Próximamente será necesario empezar a aplicar el recargo por pagos fuera de este plazo, como parte de la organización administrativa del club.

Gracias por la comprensión y apoyo 💜
Quedo atenta a cualquier duda.$template$
    )
) as template(name, body)
where not exists (
  select 1
  from public.communication_templates existing
  where existing.name = template.name
    and existing.channel = 'whatsapp'
);
