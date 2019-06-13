data {
  int N;
  int n_resp_id;
  int n_ques;
  int n_alt;
  int n_cargo;
  int n_seat;
  int n_eng;
  int n_price;
  int resp_id[N];
  int ques[N];
  int alt[N];
  int choice[N];
  int seat_int[N];
  int cargo_int[N];
  int eng_int[N];
  int price_int[N];
  int index[n_resp_id, n_ques, n_alt];
}

transformed data {
  
}

parameters {
  real b_cargo[n_cargo];
  real b_seat[n_seat];
  real b_eng[n_eng];
  real b_price[n_price];
}

transformed parameters {
  real util[N];
  for(n in 1:N){
    util[n] = b_cargo[cargo_int[n]] + b_seat[seat_int[n]] + b_eng[eng_int[n]] + b_price[price_int[n]];
  }
}

model{
  for(i in 1:n_resp_id){
    for(j in 1:n_ques){
      real u_ques[n_alt];
      int choice_selected;
      choice_selected = choice[index[i,j,1]];
      for(k in 1:n_alt){
        u_ques[k] = util[index[i,j,k]];
      }
      target += u_ques[choice_selected] - log_sum_exp(u_ques);
    }
  }
  
  b_cargo ~ normal(0, 2);
  b_seat ~ normal(0, 2);
  b_eng ~ normal(0, 2);
  b_price ~ normal(0, 2);
}

generated quantities {
  real b_cargo_c[n_cargo];
  real b_seat_c[n_seat];
  real b_eng_c[n_eng];
  real b_price_c[n_price];
  real mean_cargo;
  real mean_seat;
  real mean_eng;
  real mean_price;
  mean_cargo = mean(b_cargo);
  mean_seat = mean(b_seat);
  mean_eng = mean(b_eng);
  mean_price = mean(b_price);
  for(c in 1:n_cargo){
      b_cargo_c[c] = b_cargo[c] - mean_cargo;
  }
  for(s in 1:n_seat){
      b_seat_c[s] = b_seat[s] - mean_seat;
  }
  for(e in 1:n_eng){
      b_eng_c[e] = b_eng[e] - mean_eng;
  }
  for(p in 1:n_price){
      b_price_c[p] = b_price[p] - mean_price;
  }
}
