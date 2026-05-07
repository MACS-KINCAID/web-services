// Definiendo la funcion MaquinaHelados
function MaquinaHelados(recipiente){
  return "Poner helado en " + recipiente;
}

// Invocando MaquinaHelados y guardando la salida en result
const result = MaquinaHelados("cono");

// Imprimir resultado
console.log(result);

// ----------------------------------------------------

function square(number){
  return number * number;
}

const resSquare = square(6);
console.log(resSquare);

// ----------------------------------------------------

function Double(number){
  return number * 2;
}

const resultDouble = Double(6);
console.log(resultDouble);

// ----------------------------------------------------

function FindFirst(array){
  return array[0];
}

const resultFindFirst= FindFirst([99,98,97,96]);
console.log(resultFindFirst);

// ----------------------------------------------------

function is_programming(palabra){
  if (palabra == "programming"){
    return true;
  }else{
    return false;
  }
}
console.log(    is_programming("programming")      );
