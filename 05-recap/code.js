class App {
  params;
  constructor(){
    this.params = {};
  }

  get(path, callback){
    path
      .split("/")
      .forEach(node => {
        if(node[0] === ":"){
          this.params[node.slice(1)] = 1
        }
      });
    const req = new Request(this.params);
    const res = new Response();
    callback(req, res);
  }
}

class Response {
  send(msg){
    console.log("El servidor contesto: " + msg);
  }
}

class Request {
  params;
  constructor(params){
    this.params = params;
  }
}

const app = new App();

app.get("/objects/:id", (req, res)=>{
  return res.send("buscando:" + req.params.id);
});

