# Documentație Task-uri Verilog

## Cuprins
1. [Introducere](#introducere)
2. [Diferența Task vs Function](#diferenta-task-vs-function)
3. [Task-uri System Built-in](#task-uri-system-built-in)
4. [Task-uri Custom](#task-uri-custom)
5. [Exemple Practice](#exemple-practice)

---

## Introducere

Task-urile în Verilog sunt blocuri de cod reutilizabile, similare cu funcțiile/procedurile din alte limbaje. Ele permit:
- **Organizarea mai bună** a codului
- **Reutilizarea** logicii repetitive
- **Abstractizarea** protocoalelor complexe
- **Debugging mai ușor** prin logging structurat

---

## Diferența Task vs Function

| Caracteristică | **Task** | **Function** |
|----------------|----------|--------------|
| **Timp de execuție** | Poate consuma timp (`#delay`, `@event`) | NU poate consuma timp |
| **Output-uri** | 0 sau mai multe (prin `output`) | Returnează **1 singură valoare** |
| **Apelare alte blocuri** | Poate apela task-uri și funcții | Poate apela doar funcții |
| **Utilizare** | Statement independent | În expresii/asignări |
| **Sintaxă** | `task name; ... endtask` | `function [width] name; ... endfunction` |

### Exemplu Comparativ

```verilog
// TASK - poate avea delay și multiple outputs
task mem_write;
    input [8:0] addr;
    input [15:0] data;
    begin
        @(posedge clk);  // PERMITE delay
        address <= addr;
        data_in <= data;
        we <= 1;
        @(posedge clk);
        we <= 0;
    end
endtask

// FUNCTION - returnează imediat o singură valoare
function [15:0] add16;
    input [15:0] a, b;
    begin
        add16 = a + b;  // NU permite @(posedge clk)
    end
endfunction
```

---

## Task-uri System Built-in

### 1. **Display și Print** - Afișare în Consolă

#### `$display` - Print cu Newline
```verilog
$display("Mesaj simplu");
$display("Hex: 0x%h, Dec: %d, Bin: %b", 16'hABCD, 100, 8'b10101010);
$display("Timp: %0t ns", $time);
```

#### `$write` - Print fără Newline
```verilog
$write("Primul mesaj ");
$write("continuă pe aceeași linie\n");
```

#### Format Specifiers
| Cod | Descriere | Exemplu |
|-----|-----------|---------|
| `%h` sau `%H` | Hexazecimal | `0x%h` → `0xABCD` |
| `%d` sau `%D` | Decimal signed | `%d` → `-5` |
| `%b` sau `%B` | Binar | `%b` → `10101010` |
| `%o` sau `%O` | Octal | `%o` → `127` |
| `%t` sau `%T` | Timp | `%0t` → `1000` |
| `%s` | String | `%s` → `"text"` |
| `%0d` | Fără zero-padding | `%0d` → `5` |

---

### 2. **`$monitor`** - Monitorizare Automată

Afișează automat valorile **de fiecare dată când se schimbă** vreunul din semnalele monitorizate.

```verilog
initial begin
    $monitor("Time=%0t | clk=%b rst=%b data=%h addr=%d", 
             $time, clk, rst_b, data, addr);
    // Se printează automat la fiecare schimbare
end

// Control:
$monitoron;   // activează monitorizarea
$monitoroff;  // dezactivează monitorizarea
```

**Atenție:** Doar un singur `$monitor` activ la un moment dat (ultimul suprascrie pe celelalte).

---

### 3. **`$strobe`** - Display la Sfârșitul Time Step-ului

Similar cu `$display`, dar afișează valorile **DUPĂ** toate asignările non-blocking din time step curent.

```verilog
always @(posedge clk) begin
    data <= new_value;
    $display("Display imediat: %h", data);  // arată valoarea VECHE
    $strobe("Strobe (final): %h", data);    // arată valoarea NOUĂ
end
```

**Folosință:** Verificare valori după toate delta-cycle-urile.

---

### 4. **Controlul Simulării**

#### `$finish` - Oprire Completă
```verilog
initial begin
    #1000;
    $display("Simulare completă!");
    $finish;  // termină simularea și închide simulatorul
end

// Cu nivel de detaliu:
$finish(0);  // fără statistici
$finish(1);  // cu timp și locație
$finish(2);  // cu statistici memorie și CPU
```

#### `$stop` - Pauză Interactivă
```verilog
initial begin
    #500;
    $stop;  // pauză pentru debug interactiv
end
```

---

### 5. **Waveform și VCD**

#### `$dumpfile` și `$dumpvars` - Generare Fișiere VCD

```verilog
initial begin
    $dumpfile("waveform.vcd");        // nume fișier
    $dumpvars(0, top_module);         // 0 = toate nivelurile
    // sau selectiv:
    $dumpvars(1, regA, regB, regC);   // doar registrele specificate
end
```

**Parametri `$dumpvars`:**
- `0` = toate nivelurile ierarhice
- `1` = doar nivelul curent (fără submodule)
- `2+` = niveluri ierarhice specifice

#### Controlul Dump-ului
```verilog
$dumpon;   // pornește dump-ul
$dumpoff;  // oprește dump-ul (economisire spațiu)
$dumpall;  // forțează dump cu toate valorile curente
```

---

### 6. **Lucrul cu Fișiere**

#### Încărcare Memorie din Fișier

```verilog
reg [15:0] mem [0:511];

initial begin
    $readmemh("data.hex", mem);           // format HEX
    $readmemb("data.bin", mem);           // format BINAR
    $readmemh("init.hex", mem, 10, 20);   // doar adrese 10-20
end
```

**Fișier `data.hex` exemplu:**
```
ABCD
1234
FFFF
0000
@100  // sare la adresa 100 (hex)
CAFE
BABE
```

**Fișier `data.bin` exemplu:**
```
1010101010101010
0000000011111111
1111111100000000
```

#### Scriere/Citire Fișiere Text

```verilog
integer file_handle;

initial begin
    // Deschidere
    file_handle = $fopen("results.txt", "w");  // write mode
    // Mode-uri: "r" (read), "w" (write), "a" (append)
    
    // Scriere
    $fwrite(file_handle, "Adresa: %d, Data: 0x%h\n", addr, data);
    $fdisplay(file_handle, "Rezultat final: %d", result);
    
    // Închidere
    $fclose(file_handle);
end
```

#### Citire Character cu Character

```verilog
integer char;
integer file;

initial begin
    file = $fopen("input.txt", "r");
    while (!$feof(file)) begin
        char = $fgetc(file);
        $display("Char: %c (code: %d)", char, char);
    end
    $fclose(file);
end
```

---

### 7. **Timp și Timing**

```verilog
initial begin
    $display("Timp simulare: %0t", $time);       // integer (ns/ps)
    $display("Timp real: %f", $realtime);        // float cu zecimale
    $display("Scaled time: %0t", $stime);        // scaled based on timescale
end

// Verificare timing
$setup(data, posedge clk, 5);   // check setup time
$hold(posedge clk, data, 3);    // check hold time
```

---

### 8. **Numere Random**

```verilog
reg [15:0] random_val;
integer seed = 42;

initial begin
    // Signed random (-2^31 to 2^31-1)
    random_val = $random;
    
    // Cu seed pentru reproducibilitate
    random_val = $random(seed);
    
    // Range specific (0 to 255)
    random_val = $random % 256;
    
    // Unsigned random
    random_val = $urandom;           // 0 to 2^32-1
    random_val = $urandom % 100;     // 0 to 99
    
    // Distribuție normală
    random_val = $dist_normal(seed, mean, deviation);
end
```

---

### 9. **Debugging și Assert**

```verilog
// Assert simplu
initial begin
    if (result !== expected) begin
        $error("FAIL: expected %h, got %h", expected, result);
        $fatal(1, "Eroare critică la %0t", $time);
    end
end

// Severity levels:
$info("Informație");
$warning("Atenționare");
$error("Eroare (continuă simularea)");
$fatal(1, "Eroare fatală (oprește simularea)");
```

---

## Task-uri Custom

### Definirea unui Task

```verilog
task task_name;
    input [15:0] in1, in2;
    output [15:0] out1;
    inout [7:0] bidirectional;
    
    // Variabile locale (opțional)
    reg [15:0] temp;
    
    begin
        // Logica task-ului
        temp = in1 + in2;
        out1 = temp;
        bidirectional = bidirectional + 1;
        
        // Poate include delay
        #10;
        @(posedge clk);
    end
endtask
```

### Apelarea unui Task

```verilog
initial begin
    reg [15:0] result;
    reg [7:0] counter = 0;
    
    task_name(16'h1234, 16'h5678, result, counter);
    
    $display("Rezultat: %h, Counter: %d", result, counter);
end
```

---

## Exemple Practice

### Exemplu 1: Task pentru Scriere în Memorie

```verilog
task write_memory;
    input [8:0] address;
    input [15:0] data;
    begin
        @(posedge clk);
        addr <= address;
        din <= data;
        we <= 1;
        @(posedge clk);
        we <= 0;
        $display("[%0t] WRITE: addr=%d, data=0x%h", $time, address, data);
    end
endtask

// Folosire:
initial begin
    write_memory(9'd0, 16'hCAFE);
    write_memory(9'd1, 16'hBABE);
end
```

---

### Exemplu 2: Task pentru Citire din Memorie

```verilog
task read_memory;
    input [8:0] address;
    output [15:0] data;
    begin
        @(posedge clk);
        addr <= address;
        we <= 0;
        @(posedge clk);
        data = dout;
        $display("[%0t] READ: addr=%d, data=0x%h", $time, address, data);
    end
endtask

// Folosire:
initial begin
    reg [15:0] read_val;
    read_memory(9'd0, read_val);
    if (read_val == 16'hCAFE)
        $display("PASS: Citire corectă");
    else
        $error("FAIL: Așteptat 0xCAFE, primit 0x%h", read_val);
end
```

---

### Exemplu 3: Task pentru Reset

```verilog
task do_reset;
    input integer cycles;
    begin
        rst_b = 0;
        repeat(cycles) @(posedge clk);
        rst_b = 1;
        $display("[%0t] RESET completat (%0d cicluri)", $time, cycles);
    end
endtask

// Folosire:
initial begin
    do_reset(2);  // reset pentru 2 cicluri
end
```

---

### Exemplu 4: Task pentru Verificare cu Assert

```verilog
task check_result;
    input [15:0] expected;
    input [15:0] actual;
    input [200*8:1] test_name;  // string de max 200 caractere
    begin
        if (expected === actual)
            $display("✓ PASS: %s", test_name);
        else begin
            $error("✗ FAIL: %s", test_name);
            $display("  Expected: 0x%h, Got: 0x%h", expected, actual);
        end
    end
endtask

// Folosire:
initial begin
    check_result(16'hABCD, dout, "Test citire adresa 0");
end
```

---

### Exemplu 5: Testbench Complet cu Task-uri

```verilog
`timescale 1ns/1ps
module advanced_tb;
    reg clk, rst_b, we;
    reg [8:0] addr;
    reg [15:0] din;
    wire [15:0] dout;
    
    // DUT
    memory_512x16 mem(.*);
    
    // Clock generation
    initial clk = 0;
    always #25 clk = ~clk;
    
    // Task: Reset
    task do_reset;
        input integer cycles;
        begin
            rst_b = 0;
            repeat(cycles) @(posedge clk);
            rst_b = 1;
            $display("[%0t] Reset done", $time);
        end
    endtask
    
    // Task: Write
    task mem_write;
        input [8:0] a;
        input [15:0] d;
        begin
            @(posedge clk);
            addr <= a;
            din <= d;
            we <= 1;
            @(posedge clk);
            we <= 0;
            $display("[%0t] WR[%d]=0x%h", $time, a, d);
        end
    endtask
    
    // Task: Read
    task mem_read;
        input [8:0] a;
        output [15:0] d;
        begin
            @(posedge clk);
            addr <= a;
            we <= 0;
            @(posedge clk);
            d = dout;
            $display("[%0t] RD[%d]=0x%h", $time, a, d);
        end
    endtask
    
    // Task: Check
    task check;
        input [15:0] exp, act;
        input [100*8:1] name;
        begin
            if (exp === act)
                $display("✓ %s", name);
            else
                $error("✗ %s: exp=0x%h, got=0x%h", name, exp, act);
        end
    endtask
    
    // Main test
    reg [15:0] rd;
    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0, advanced_tb);
        
        do_reset(2);
        
        // Test write/read
        mem_write(9'd0, 16'hCAFE);
        mem_read(9'd0, rd);
        check(16'hCAFE, rd, "Test addr 0");
        
        // Test sequence
        repeat(10) begin
            automatic integer i = $random % 512;
            automatic reg [15:0] val = $random;
            mem_write(i, val);
            mem_read(i, rd);
            check(val, rd, "Random test");
        end
        
        #100 $finish;
    end
endmodule
```

---

## Best Practices

### 1. **Naming Convention**
```verilog
// Bune practici:
task do_reset;          // prefix "do_" pentru acțiuni
task check_result;      // prefix "check_" pentru verificări
task mem_write;         // nume descriptive

// Evită:
task t1;                // nume neclar
task x;                 // prea scurt
```

### 2. **Logging Consistent**
```verilog
task mem_write;
    input [8:0] addr;
    input [15:0] data;
    begin
        // ... logică ...
        $display("[%0t] WR[%3d]=0x%04h", $time, addr, data);
        //        ^timp  ^3digits  ^4 hex digits
    end
endtask
```

### 3. **Parametrizare**
```verilog
task generic_write #(
    parameter ADDR_W = 9,
    parameter DATA_W = 16
)(
    input [ADDR_W-1:0] addr,
    input [DATA_W-1:0] data
);
    // ... logică ...
endtask
```

### 4. **Error Handling**
```verilog
task safe_read;
    input [8:0] addr;
    output [15:0] data;
    begin
        if (addr > 511) begin
            $error("Adresă invalidă: %d", addr);
            data = 16'hXXXX;
        end else begin
            // ... citire normală ...
        end
    end
endtask
```

---

## Resurse Suplimentare

- **IEEE 1364-2005** - Verilog HDL Standard
- **IEEE 1800-2017** - SystemVerilog Standard (task-uri avansate)
- Simulatoare: Icarus Verilog, ModelSim, VCS, Verilator
- Waveform Viewers: GTKWave, Verdi, DVE

---

## Rezumat Quick Reference

| Task | Scop | Exemplu |
|------|------|---------|
| `$display` | Print cu newline | `$display("val=%h", data);` |
| `$write` | Print fără newline | `$write("msg");` |
| `$monitor` | Auto-print la schimbare | `$monitor("t=%0t d=%h", $time, data);` |
| `$strobe` | Print după delta-cycles | `$strobe("final=%h", result);` |
| `$finish` | Oprește simularea | `$finish;` |
| `$dumpfile` | Setează fișier VCD | `$dumpfile("wave.vcd");` |
| `$dumpvars` | Dump semnale | `$dumpvars(0, top);` |
| `$readmemh` | Încarcă memorie (HEX) | `$readmemh("init.hex", mem);` |
| `$fopen` | Deschide fișier | `f=$fopen("out.txt","w");` |
| `$fwrite` | Scrie în fișier | `$fwrite(f, "data=%h\n", val);` |
| `$random` | Număr random | `r=$random%100;` |
| `$time` | Timp curent | `t=$time;` |
| `$error` | Mesaj de eroare | `$error("Fail at %0t", $time);` |

---

**Creat:** 8 Noiembrie 2025  
**Versiune:** 1.0  
**Autor:** GitHub Copilot pentru proiectul PROCESSOR
