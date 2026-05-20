// Definir la forma de todas las peliculas
class Pelicula {
  // Atributos
  titulo;
  duracion;
  genero;
  reparto;
  guion;
  sinopsis;

  // Métodos
  // Todas las peliculas tienen la capacidad para contar una historia
  cuentaHistoria(){
    console.log(this.guion);
  }

  // Todas las peliculas tienen la capacidad de mostrar su titulo
  mostrarTitulo(){
    console.log("Mi titulo es: " + this.titulo);
  }
}

// Instanciar (crear) un objeto siguiendo el plano/molde de Pelicula
const juegosHambre = new Pelicula();
juegosHambre.titulo = "Los juegos del hambre";
juegosHambre.duarcion = 90;
juegosHambre.genero = "sci-fi";
juegosHambre.reparto = ["JenLaw", "LiamHens"];
juegosHambre.guion = "En una galaxia muy muy lejana....";
juegosHambre.sinopsis = "Dos jovenes seleccionados para participar en un juego mortal";
juegosHambre.cuentaHistoria();


const halloween = new Pelicula();
halloween.titulo = "Halloween";
halloween.mostrarTitulo();


