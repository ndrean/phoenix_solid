import { onMount } from "solid-js";
import { Chart, Title, Tooltip, Legend, Colors } from "chart.js";
import { Line } from "solid-chartjs";

export default (props) => {
  onMount(() => {
    Chart.register(Title, Tooltip, Legend, Colors);
  });

  const options = {
    responsive: false,
    maintainAspectRatio: false,

    backgroundColor: "#FFFFFF",
    borderColor: "#36A2EB",
    plugins: {
      title: {
        display: true,
        text: "Solid Chart.js: Bitcoin from CoinCap.IO",
      },
      colors: {
        forceOverride: true,
      },
    },
  };

  return <Line data={props.data} options={options} width={350} height={200} />;
};
