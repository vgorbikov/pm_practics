set N ordered;   # работники
set T ordered;   # задачи

param effort{T} >= 0;       # трудоёмкость задач
param pref{N,T} >= 0;       # предпочтения работников

# переменные
var x{N,T} binary;          # назначение (1 если задача t назначена работнику n)

# каждая задача должна быть назначена ровно одному работнику
s.t. Assign{t in T}: sum{n in N} x[n,t] = 1;

# нагрузка на каждого работника
var load{n in N} = sum{t in T} effort[t] * x[n,t];

# максимум нагрузки
var maxLoad >= 3;
s.t. DefMaxLoad{n in N}: load[n] <= maxLoad;

# предпочтения (сумма, среднее по назначенным задачам)
var totalPref{n in N} = sum{t in T} pref[n,t] * x[n,t];
var assigned{n in N} = sum{t in T} x[n,t];
var avgPref{n in N} = if assigned[n] > 0 then totalPref[n] / assigned[n] else 0;

# минимум среднего предпочтения
var minAvgPref;
s.t. DefMinAvg{n in N}: minAvgPref <= avgPref[n];

# --- границы для нормировки ---
param Lmin := ceil(sum{t in T} effort[t] / card(N));
param Lmax := sum{t in T} effort[t];
param Pmin := min{n in N, t in T} pref[n,t];
param Pmax := max{n in N, t in T} pref[n,t];

# --- нормированные критерии ---
var f1;
var f2;

s.t. DefF1: f1 = (maxLoad - Lmin) / (Lmax - Lmin + 1e-6);
s.t. DefF2: f2 = (Pmax - minAvgPref) / (Pmax - Pmin + 1e-6);

# --- веса для свертки ---
param alpha := 0.5;
param beta  := 0.5;

# --- целевая функция ---
minimize Obj: alpha * f1 + beta * f2;
