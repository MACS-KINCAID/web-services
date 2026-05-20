// La forma de todos los alumnos
class Alumno {
  nombre;
  edad;
  matricula;

  constructor(nombreSolicitante, edadSolicitante){
    this.nombre = nombreSolicitante;
    this.edad = edadSolicitante;
    this.matricula = Math.floor(Math.random()*1000);
  }

  presentarse(){
    console.log(this.nombre);
    console.log(this.edad);
    console.log(this.matricula);
  }
}

const mit = new Alumno("Mitsiu", 32);
mit.presentarse();

