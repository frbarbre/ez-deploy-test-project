async function getData() {
  const response = await fetch(process.env.API_URL + "/api/test");
  const data = await response.json();

  return data;
}

export default async function Home() {
  const data = await getData();

  return <pre>{JSON.stringify(data, null, 2)}</pre>;
}
