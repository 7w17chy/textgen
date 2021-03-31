# Grammar
```
Dear \(N)!

Some text, even more text, \(P), text!

\(Q)
Your Name
```
- \\() introduces a template, the character within the `()` specifies which kind of
  template it will be (experimental)
  - P => pronoun
  - Q => quote
  - N => name
- Users should be able to define their own templates (seperate file)
- Substitutions for these template arguments can be listed in the header of the file 
  (format not specified yet) and will be, together with "pointers" (more specifically,
  id's) to the templates in the text, passed to a lua script
- Implement "std"/useful functions for Lua
