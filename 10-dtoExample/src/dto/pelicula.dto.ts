export interface PeliculaDto {
  "nombre":string,
  "duracion":number,
  "fecha_estreno": {
    "dia":number,
    "mes":number,
    "anio":number
  },
  "generos": string[]
};
