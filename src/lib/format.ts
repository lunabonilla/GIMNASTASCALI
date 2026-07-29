export const formatClubTime = (value: string) => {
  const [hourText = "0", minute = "00"] = value.split(":");
  const hour = Number(hourText);
  const displayHour = hour % 12 || 12;
  const period = hour < 12 ? "a. m." : "p. m.";
  return `${displayHour}:${minute} ${period}`;
};

