---
theme:
    override:
        code:
            #theme_name: "Monokai Extended Bright"
        default:
            colors:
                background: "10141c"
---
Partial 1 Recap
===
<!-- column_layout: [1,1] -->
<!-- column: 0 -->
Mitsiu Alejandro Carreño Sarabia
<!-- column: 1 -->

<!-- reset_layout -->
<!-- end_slide -->

# Course structure **Partial test**
- `1st Partial = 30%`
- - Autoevaluation = 5%
- - Theorical evaluation = 40%
- - Practical evaluation = 55%
<!-- end_slide -->

`Agenda`    
├── Autoevaluation   
├── Token system      
├── Recap        
└── Evaluation   

<!-- end_slide -->

# Autoevaluation
Using your `@alumnos.upa.edu.mx` email answer the following form:
https://forms.gle/hXf7KbSB9Sp7sa9b8

<!-- end_slide -->

## Token system
Mit managed
- All tokens are spent on the current partial


Self managed
- You allocate or reserve tokens prior evaluations, non changeable decision.

<!-- end_slide -->

### Recap
- Function
- - What is it?
- - Which syntax/keywords does it use?
- Parameter
- - How is it usefull?
- - Which syntax/keywords does it use?
- Class 
- - What is it?
- - Which syntax/keywords does it use?
- Object (instance)
- - What is it?
- - Which syntax/keywords does it use?
- Constructor
- - What is it?
- - How is it usefull?
- - Which syntax/keywords does it use?
- Http Status code
- - How is it segmented?
- - What's the meaning of each segment?
<!-- end_slide -->

### Recap
- Http methods
- - Which exists (CRUD)?
- - Which operation/action do they perform
- Json
- - What does `[]` means in JSON
- - What does `{}` means in JSON
- - How is `:` used in JSON
- Client-Server
- - What's the difference between client & server
- - What are the benefits of this model?
- - Describe in chronological order the interaction between them
<!-- end_slide -->

### Recap Practical
```js
app.get("/objects/:id", (req, res)=>{
  return res.send("buscando:" + req.params.id);
});
```

Code rules:
1. app is an instance of App class
2. req is an instance of Request class
3. res is an instance of Response class
4. params is a json with an attribute id

<!-- end_slide -->

#### Evaluation
Now it's show off time!
