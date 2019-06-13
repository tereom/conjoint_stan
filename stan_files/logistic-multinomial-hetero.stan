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
    real mu_cargo[n_cargo];
    real mu_seat[n_seat];
    real mu_eng[n_eng];
    real mu_price[n_price];
    
    real<lower=0> sigma_cargo[n_cargo];
    real<lower=0> sigma_seat[n_seat];
    real<lower=0> sigma_eng[n_eng];
    real<lower=0> sigma_price[n_price];
    
    real v_cargo[n_resp_id, n_cargo];
    real v_seat[n_resp_id, n_seat];
    real v_eng[n_resp_id, n_eng];
    real v_price[n_resp_id,  n_price];
}

transformed parameters {
    real util[N];
    real b_cargo[n_resp_id, n_cargo];
    real b_seat[n_resp_id, n_seat];
    real b_eng[n_resp_id, n_eng];
    real b_price[n_resp_id,  n_price];
    
    for(i in 1:n_resp_id){
        for(j in 1:n_cargo){
            b_cargo[i,j] = v_cargo[i, j] * sigma_cargo[j] + mu_cargo[j];
        }
        for(j in 1:n_seat){
            b_seat[i,j] = v_seat[i, j] * sigma_seat[j] + mu_seat[j];
        }
        for(j in 1:n_eng){
            b_eng[i,j] = v_eng[i, j] * sigma_eng[j] + mu_eng[j];
        }
        for(j in 1:n_price){
            b_price[i,j] = v_price[i, j] * sigma_price[j] + mu_price[j];
        }
    }
    for(n in 1:N){
        util[n] = b_cargo[resp_id[n], cargo_int[n]] + b_seat[resp_id[n], seat_int[n]] + b_eng[resp_id[n], eng_int[n]] + b_price[resp_id[n], price_int[n]];
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
    
    mu_cargo ~ normal(0, 2);
    mu_seat ~ normal(0, 2);
    mu_eng ~ normal(0, 2);
    mu_price ~ normal(0, 2);
    
    sigma_cargo ~ normal(0, 2);
    sigma_seat ~ normal(0, 2);
    sigma_eng ~ normal(0, 2);
    sigma_price ~ normal(0, 2);
    
    for(i in 1:n_resp_id){
        for(j in 1:n_cargo){
            v_cargo[i, j] ~ normal(0, 1);
        }
        for(j in 1:n_seat){
            v_seat[i, j] ~ normal(0, 1);
        }
        for(j in 1:n_eng){
            v_eng[i, j] ~ normal(0, 1);
        }
        for(j in 1:n_price){
            v_price[i, j] ~ normal(0, 1);
        }
    }
}

generated quantities {
  real mu_cargo_c[n_cargo];
  real mu_seat_c[n_seat];
  real mu_eng_c[n_eng];
  real mu_price_c[n_price];
  real mean_cargo;
  real mean_seat;
  real mean_eng;
  real mean_price;
  mean_cargo = mean(mu_cargo);
  mean_seat = mean(mu_seat);
  mean_eng = mean(mu_eng);
  mean_price = mean(mu_price);
  for(c in 1:n_cargo){
      mu_cargo_c[c] = mu_cargo[c] - mean_cargo;
  }
  for(s in 1:n_seat){
      mu_seat_c[s] = mu_seat[s] - mean_seat;
  }
  for(e in 1:n_eng){
      mu_eng_c[e] = mu_eng[e] - mean_eng;
  }
  for(p in 1:n_price){
      mu_price_c[p] = mu_price[p] - mean_price;
  }
}
