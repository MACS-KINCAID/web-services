class Cofre{
  capacidad;
  ubicacion;
  contenido = [];

  guardar(item){
    this.capacidad = this.capacidad - 1;
    this.contenido.push(item);
  }

  sacar(){
    this.capacidad = this.capacidad + 1;
    return this.contenido.pop();
  }

  listar(){
    console.log("El cofre tiene:" + this.contenido);
  }
}

const cofre1 = new Cofre()
cofre1.guardar("espada");
cofre1.guardar("pocima");
cofre1.listar();
const inventario = cofre1.sacar();
console.log("Inventario con:" + inventario);
cofre1.listar();

