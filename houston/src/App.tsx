import { useEffect, useState } from 'react';
import './App.css';

function App() {
  const [locations, setLocations] = useState<{name: string}[]>([])

  useEffect(() => {
    fetch('http://apollo-lb-691500996.eu-west-2.elb.amazonaws.com/locations').then(async resp => {
      const data = await resp.json()
      setLocations(data.data)
    })
  }, [])

  return (
    <div className="App">
      <ul>
        {locations.map(location => <li>{location.name}</li>)}
      </ul>
    </div>
  );
}

export default App;
