const express = require("express");
const app = express();
app.use(express.json());
app.set("trust proxy", true);

let objects =
[
  {
    "id": "1",
    "name": "Google Pixel 6 Pro",
    "data": {
      "color": "Cloudy White",
      "capacity": "128 GB"
    }
  },
  {
    "id": "2",
    "name": "Apple iPhone 12 Mini, 256GB, Blue",
    "data": null
  },
  {
    "id": "3",
    "name": "Apple iPhone 12 Pro Max",
    "data": {
      "color": "Cloudy White",
      "capacity GB": 512
    }
  },
  {
    "id": "4",
    "name": "Apple iPhone 11, 64GB",
    "data": {
      "price": 389.99,
      "color": "Purple"
    }
  },
  {
    "id": "5",
    "name": "Samsung Galaxy Z Fold2",
    "data": {
      "price": 689.99,
      "color": "Brown"
    }
  },
  {
    "id": "6",
    "name": "Apple AirPods",
    "data": {
      "generation": "3rd",
      "price": 120
    }
  },
  {
    "id": "7",
    "name": "Apple MacBook Pro 16",
    "data": {
      "year": 2019,
      "price": 1849.99,
      "CPU model": "Intel Core i9",
      "Hard disk size": "1 TB"
    }
  },
  {
    "id": "8",
    "name": "Apple Watch Series 8",
    "data": {
      "Strap Colour": "Elderberry",
      "Case Size": "41mm"
    }
  },
  {
    "id": "9",
    "name": "Beats Studio3 Wireless",
    "data": {
      "Color": "Red",
      "Description": "High-performance wireless noise cancelling headphones"
    }
  },
  {
    "id": "10",
    "name": "Apple iPad Mini 5th Gen",
    "data": {
      "Capacity": "64 GB",
      "Screen size": 7.9
    }
  },
  {
    "id": "11",
    "name": "Apple iPad Mini 5th Gen",
    "data": {
      "Capacity": "254 GB",
      "Screen size": 7.9
    }
  },
  {
    "id": "12",
    "name": "Apple iPad Air",
    "data": {
      "Generation": "4th",
      "Price": "419.99",
      "Capacity": "64 GB"
    }
  },
  {
    "id": "13",
    "name": "Apple iPad Air",
    "data": {
      "Generation": "4th",
      "Price": "519.99",
      "Capacity": "256 GB"
    }
  }
];

let nextId = 14;

app.get("/objects", (req, res) => {
  console.log(req.ip);
  res.json(objects);
});

app.get("/objects/:id", (req, res)=>{
  const obj = objects.find(o => o.id === req.params.id);
  if(!obj)
    return res.status(404).json({message: "Object with id = ${req.params.id} not found"});
  res.json(obj);
});

app.post("/objects", (req, res)=>{
  const { name, data } = req.body;
  if(!name)
    return res.status(400).json({message:"Field \"name\" is required"});
  const newObj = { id: String(nextId++), author: req.ip, name, data: data ?? null, createdAt: new Date().toISOString()};
  objects.push(newObj);
  res.status(201).json(newObj);
});

app.put("/objects/:id", (req, res)=>{
  const index = objects.findIndex(o => o.id == req.params.id);
  if (index === -1)
    return res.status(404).json({message: `Object with id = ${req.params.id} not found`});
  const { name, data } = req.body;
  if(!name)
    return res.status(400).json({message: "Field \"name\" is required"})
  objects[index] = { id: req.params.id, author: req.ip, name, data: data ?? null, createdAt: objects[index].createdAt, updatedAt: new Date().toISOString() };
  res.json(objects[index]);
});

app.patch('/objects/:id', (req, res) =>{
  const index = objects.findIndex(o => o.id === req.params.id);
  if (index === -1)
    return res.status(404).json({message: `Object with id = ${req.params.id} not found`});
  objects[index] = {...objects[index], ...req.body, id: req.params.id, author: req.ip, updatedAt: new Date().toISOString()} ;
  res.json(objects[index]);
});

app.delete("/objects/:id", (req, res)=>{
  const index = objects.findIndex(o => o.id === req.params.id);
  if (index === -1)
    return res.status(404).json({message: `Object with id = ${req.params.id} not found`});
  objects.splice(index, 1);
  res.json({message: `Object with id = ${req.params.id}, has been deleted`})
});

app.listen(3000, ()=> console.log("Running on: 3000"))
