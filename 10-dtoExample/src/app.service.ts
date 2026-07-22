import { Injectable } from '@nestjs/common';
import { PeliculaDto } from './dto/pelicula.dto';

@Injectable()
export class AppService {
  //pelicula : {"nombre":string, "duracion":number, "fecha_estreno":{"dia":number, "mes":number, "anio":number}, "generos":string[]} = {
  pelicula : PeliculaDto = {
    "nombre": "",
    "duracion": 0,
    "fecha_estreno": {
      "dia": 0,
      "mes": 0,
      "anio": 0
    },
    generos: []
  };

  actualizarNombreDuracion(newNombre: string, newDuracion:number):boolean{
    this.pelicula.nombre = newNombre;
    this.pelicula.duracion = newDuracion;
    return true;
  }

  actualizarFecha(newDia: number, newMes: number, newAnio: number): boolean{
    this.pelicula["fecha_estreno"]["dia"] = newDia;
    this.pelicula["fecha_estreno"].mes = newMes;
    this.pelicula.fecha_estreno.anio = newAnio;
    return true;
  }

}
