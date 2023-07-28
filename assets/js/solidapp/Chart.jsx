import { onMount } from "solid-js";
import { Chart, Title, Tooltip, Legend, Colors } from "chart.js";
import { Line } from "solid-chartjs";

export default (props) => {
  onMount(() => {
    Chart.register(Title, Tooltip, Legend, Colors);
  });

  const data = (multi) => ({
    labels: ["January", "February", "March", "April", "May"],
    datasets: [
      {
        label: "Sales",
        data: [50, 60, 70, 80, 90].map((x) => x * multi),
      },
    ],
  });

  const options = {
    responsive: false,
    maintainAspectRatio: false,
  };

  return (
    <Line data={data(props.multi)} options={options} width={200} height={200} />
  );
};
