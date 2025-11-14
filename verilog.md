```verilog
always @(posedge clk) begin
    a <= b;        // NON-BLOCKING
    d = c;         // BLOCKING
end

assign x = ~a;

initial begin
    @(posedge clk);
    #0 y = x;
    #1 z = x;
end
```

```yaml
┌──────────────────────────────────────────────────────────────┐
│                         TIMP = 100 ns                         │
└──────────────────────────────────────────────────────────────┘

CLK:       ↑ posedge clk

DELTA 0:
    • detect posedge
    • run all @(posedge clk)
          a <= b        (NB, aplicat la finalul DELTA 0)
          d = c         (B, imediat)
    • end of delta 0 → a = b

DELTA 1:
    • logică combinatională:
          x = ~a        (bazat pe noul a)

DELTA 2:
    • #0 code:
          y = x         (x este stabil)

TIMP AVANSEAZĂ (100ns → 101ns)

#1:
    • z = x             (timp real avansat; acțiune 1ns mai târziu)

```
