import { useEffect, useState } from 'react';
import './App.css';

function App() {
  const [locations, setLocations] = useState<{name: string}[]>([])

  useEffect(() => {
    fetch('http://localhost:4000/locations').then(async resp => {
      const data = await resp.json()
      setLocations(data.data)
    })
  }, [])

  return (
    <div className="App">
      {locations.map(location => <div>{location.name}</div>)}
    </div>
  );
}

export default App;
