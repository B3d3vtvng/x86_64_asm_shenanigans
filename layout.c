int stoi(char* str){
    int res = 0;
    int cur_exp = len()-1;
    int cur_idx = 0;
    int exp_res, cur_char;
    while (cur_idx >= 0){
        exp_res = pow10(cur_exp)
        cur_char = &(str+cur_idx);
        cur_char = cur_char + expr_res;
        res = res + cur_char
    }
}

int itoa(uint64_t num, char* buf){
    int trailing_0 = 1;
    int cur_exp = 20;
    int exp_res;
    int quotient, remainder;
    while (cur_exp >= 0){
        exp_res = pow10(cur_exp);
        quotient, remainder = num / exp_res;
        num = remainder;
        if (quotient == 0 && trailing_0 == 1){
            continue;
        }
        if (quotient != 0 && trailing_0 == 1){
            trailing_0 = 0;
        }
        quotient = quotient + 48;
        &(buf + 20 - cur_exp) = quotient;
    }
}