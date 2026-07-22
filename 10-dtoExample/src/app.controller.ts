import { Controller, Get, Post, Query, Param, ParseIntPipe } from '@nestjs/common';
import { AppService } from './app.service';
import type { PeliculaDto } from './dto/pelicula.dto';

@Controller()
export class AppController {
  constructor(private readonly appService: AppService) {}

  @Get('pelicula/nombre/:newNombre/duracion/:newDuracion')
  actualizarNombreDuracion(
    @Param('newNombre') newNombre,
    @Param('newDuracion', ParseIntPipe) newDuracion: number
  ):boolean{
    return this.appService.actualizarNombreDuracion(newNombre, newDuracion);
  }

  @Post('pelicula/fecha_estreno')
  actualizarFecha(
    @Query('dia', ParseIntPipe) newDia,
    @Query('mes', ParseIntPipe) newMes,
    @Query('anio', ParseIntPipe) newAnio
  ): boolean{
    return this.appService.actualizarFecha(newDia, newMes, newAnio);
  }

  @Get('pelicula')
  //getPelicula():{"nombre":string, "duracion":number, "fecha_estreno":{"dia":number, "mes":number, "anio":number}, "generos":string[]}{
  getPelicula(): PeliculaDto{
    return this.appService.pelicula;
  }

}
