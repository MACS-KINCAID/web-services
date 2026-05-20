class Perro {
  nombre;
  raza;
  color;
  muletilla;
  pos_muletilla;

  constructor(nombreDePerro, muletillaDePerro, posMuletPerro){
    this.nombre = nombreDePerro;
    this.muletilla = muletillaDePerro;
    this.pos_muletilla = posMuletPerro;
  }

  hablar(dialogo){
    if(this.pos_muletilla == "pre"){
      console.log(this.muletilla+dialogo);
    }else if (this.pos_muletilla == "post"){
      console.log(dialogo + this.muletilla);
    }else{
      console.log(dialogo);
    }
  }
}

const scooby = new Perro("Scooby-doo", "ohhoo", "post");
scooby.hablar("Estas seguro shaggi");


