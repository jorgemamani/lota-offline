------------------------------------------
# **Flutter Template:**<br> 

## **Descripción**
Plantilla para crear proyectos mobile de Siltium
<br>
<br>

## **Clase Network para recibir mensajes customs**

Agregar en la carpeta `enums`, la caperta `support` y crear el archivo que contenga los mensajes custom del proyecto en uso

Ejemplo (Medicenter):
```enum
enum ExceptionHandlingCodesEnum {
  cAUTH_1000_EmailAlreadyInUse("AUTH-1000"),
  cAUTH_1001_UsernameAlreadyInUse("AUTH-1001"),
  cUSER_1001_UsernameAlreadyInUse("USER-1001");

  final String value;
  const ExceptionHandlingCodesEnum(this.value);
}
```
Nota: se usa la `c` por "código" , seguido del `código` , seguido de una breve descripción
