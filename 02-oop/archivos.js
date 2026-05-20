import fs from "node:fs/promises";

class Archivo {
  nombre;
  extension;
  ruta;
  contenido;

  constructor (nom, ext, rut){
    this.nombre = nom;
    this.extension = ext;
    this.ruta = rut;
    this.contenido = "";
  }

  mostrarContenido(){
    console.log(this.contenido);
  }

  escribirContenido(nuevoContenido){
    this.contenido = this.contenido + nuevoContenido;
  }

  async guardar(){
    try{
      //'/Users/joe/test.txt'
      const rutaCompleta = this.ruta + "/" + this.nombre + "." + this.extension;
      console.log(rutaCompleta);
      await fs.writeFile(rutaCompleta, this.contenido);
    }catch(err){
      console.log(err);
    }
  }
}

const notas = new Archivo("13-05-26", "txt", ".");

notas.escribirContenido("Constructor-Método que se ejecuta al crear un objeto");

notas.mostrarContenido();

notas.escribirContenido("Contiene lógica de creación");

notas.mostrarContenido();

notas.guardar();

