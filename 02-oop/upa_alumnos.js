
class Alumno{
  // Todos los alumnos tienen:
  nombre;
  matricula;
  carrera;

  // Todos los alumnos pueden hacer:
  // Crearse
  constructor(nom, mat, carr){
    this.nombre = nom;
    this.matricula = mat;
    this.carrera = carr;
  }

  decirPresente(){
    console.log(this.nombre + ": Presente");
  }
}

class Universidad {
  // Todas las universdidades tienen:
  carreras = []
  alumnos = []
  nombre;

  // Todas las universidades hacen:
  // Crearse
  constructor(nombreInicial, carrerasIniciales){
    // El nombre de esta universidad al momento de crearse
    // va a ser lo que manden en nombreInicial
    this.nombre = nombreInicial;
    this.carreras = carrerasIniciales;
  }

  // Regresar alumnos inscritos
  obtenerAlumnos(){
    return this.alumnos;
  }

  // Inscribir nuevos alumnos
  inscribirAlumno(nombreAlumno, carreraElegida){
    const alumnosInscritos = this.alumnos.length + 1;
    const nuevoAlumno = new Alumno(nombreAlumno, "UP2500"+alumnosInscritos, carreraElegida);
    this.alumnos.push(nuevoAlumno);
  }
}

const upa = new Universidad("UPA", ["ISEI", "ELEC"]);
upa.inscribirAlumno("Mitsiu", "ISEI");
const listaAlumnos = upa.obtenerAlumnos();

for(let i = 0; i<listaAlumnos.length; i++){
  const alumno = listaAlumnos[i];
  console.log("Profesor: " + alumno.nombre);
  alumno.decirPresente();
}

