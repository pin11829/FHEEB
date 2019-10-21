pragma solidity >=0.4.21 <0.6.0;

contract SecondAuction
{
    uint public time;
    uint _output;
    uint Publickey_p;
    int alpha;
    int [6] pk_c;
    int [6] pk_B;
    //uint SCARAB_T = 3;
    //uint SCARAB_S = 2;
    event timeStamper(uint timestamp, address sender, uint _output);
    constructor() public
    {
        // Only needed for a private network
    }

    //Publickey
    function Publickey(int _input) public {
        Publickey_p = uint(_input);
        pk_c = #upload_publickey_parameter;
        pk_B = #upload_publickey_parameter;
        alpha = #upload_publickey_parameter;
	}

    function e_mul(uint a, uint b) public view returns(uint) {
        return mulmod(uint(a), uint(b), Publickey_p);
    }

    function e_add(uint a, uint b) public view returns(uint) {
        return addmod(uint(a), uint(b), Publickey_p);
    }

    function e_half_add(uint a, uint b) public view returns(uint sum, uint c_out) {
        sum = e_add(a, b);
        c_out = e_mul(a, b);
    }

    function e_full_add(uint a, uint b, uint c_in) public view returns(uint sum, uint c_out) {
        uint temp;
        uint temp2;
        temp = addmod(a, b, Publickey_p);
        sum = addmod(temp, c_in, Publickey_p);
        temp = mulmod(a, b, Publickey_p);
        temp2 = mulmod(c_in, a, Publickey_p);
        temp = addmod(temp, temp2, Publickey_p);
        temp2 = mulmod(c_in, b, Publickey_p);
        c_out = addmod(temp, temp2, Publickey_p);
        return (sum, c_out);
    }

    function e_operation_bits(int a, int b) public {
        uint sum;
        sum = addmod(uint(a), uint(b), Publickey_p);
        sum = addmod(uint(a), uint(b), Publickey_p);
        emit timeStamper(time, msg.sender, sum);
    }

    function e_operation_sorting_bits(int [10][2] memory Bidder) public {
        e_sorting(Bidder);
        e_sorting(Bidder);
        emit timeStamper(time, msg.sender, uint(Bidder[0][0]));
    }

    function e_swap(int[10] memory a, int[10] memory b) public view returns(uint) {
        uint c_out;
        uint i;
        uint beta;
        //merger three matriz
        uint [10] memory Inverse_array = [encrypt_pk(1), encrypt_pk(1), encrypt_pk(1), encrypt_pk(1), encrypt_pk(1), encrypt_pk(1), encrypt_pk(1), encrypt_pk(1), encrypt_pk(1), encrypt_pk(1)];
        uint [10] memory Ones_array = [encrypt_pk(0), encrypt_pk(0), encrypt_pk(0), encrypt_pk(0), encrypt_pk(0), encrypt_pk(0), encrypt_pk(0), encrypt_pk(0), encrypt_pk(0), encrypt_pk(1)];
        uint [10] memory Temp_array = [uint(0), uint(0), uint(0), uint(0), uint(0), uint(0), uint(0), uint(0), uint(0), uint(0)];
        for(i=0; i<10; i++){
            Temp_array[9-i] = e_add(Inverse_array[9-i], uint(b[9-i]));
        }
        c_out = encrypt_pk(0);
        for(i=0; i<10; i++){
            (Temp_array[9-i], c_out) = e_full_add(Temp_array[9-i], Ones_array[9-i], c_out);
            c_out = recrypt(c_out);
        }
        c_out = encrypt_pk(0);
        for(i=0; i<10; i++){
            (beta, c_out) = e_full_add(uint(a[9-i]), Temp_array[9-i], c_out);
            c_out = recrypt(c_out);
        }
        return beta;
    }

    function e_sorting(int [10][2] memory Bidder) public {
        uint c_one;
        uint sum;
        uint beta;
        uint [10] memory Temp_array = [uint(0), uint(0), uint(0), uint(0), uint(0), uint(0), uint(0), uint(0), uint(0), uint(0)];
        uint [10] memory Result_array = [uint(0), uint(0), uint(0), uint(0), uint(0), uint(0), uint(0), uint(0), uint(0), uint(0)];

        for(uint i=0; i<1; i++){
            for(uint j=0; j<2-i-1; j++){//9-i-1
                beta = e_swap(Bidder[j], Bidder[j+1]);
                beta = recrypt(beta);
                //beta*A
                for(uint k=0; k<10; k++){
                    Temp_array[9-k] = e_mul(beta, uint(Bidder[j][9-k]));
                    Temp_array[9-k] = recrypt(Temp_array[9-k]);
                }

                //1-beta = sum
                c_one = encrypt_pk(1);//Encrypt 1
                sum = e_add(c_one, beta);
                //(1-beta)*B
                for(k=0; k<10; k++){
                    Result_array[9-k] = e_mul(sum, uint(Bidder[j+1][9-k]));
                    Result_array[9-k] = recrypt(Result_array[9-k]);
                }
                for(k=0; k<10; k++){
                    Temp_array[9-k] = e_add(Temp_array[9-k], Result_array[9-k]);
                }
                //(1-beta)*A
                for(k=0; k<10; k++){
                    Result_array[9-k] = e_mul(sum, uint(Bidder[j][9-k]));
                    Result_array[9-k] = recrypt(Result_array[9-k]);
                }
                //beta*B
                for(k=0; k<10; k++){
                    Bidder[j+1][9-k] = int(e_mul(beta, uint(Bidder[j+1][9-k])));
                    Bidder[j+1][9-k] = int(recrypt(uint(Bidder[j+1][9-k])));
                }
                for(k=0; k<10; k++){
                    Bidder[j+1][9-k] = int(e_add(uint(Bidder[j+1][9-k]), Result_array[9-k]));
                }
                for(k=0; k<10; k++){
                    Bidder[j][9-k] = int(Temp_array[9-k]);
                }
            }
        }
        emit timeStamper(time, msg.sender, uint(Bidder[0][0]));
    }

    function recrypt(uint ciphertext) public view returns(uint) {
        uint [3][6] memory C = [[uint(0), uint(0), uint(0)], [uint(0), uint(0), uint(0)], [uint(0), uint(0), uint(0)], [uint(0), uint(0), uint(0)], [uint(0), uint(0), uint(0)], [uint(0), uint(0), uint(0)]];
        uint [5][5] memory H = [[uint(0), uint(0), uint(0), uint(0), uint(0)], [uint(0), uint(0), uint(0), uint(0), uint(0)], [uint(0), uint(0), uint(0), uint(0), uint(0)], [uint(0), uint(0), uint(0), uint(0), uint(0)], [uint(0), uint(0), uint(0), uint(0), uint(0)]];
        uint temp;
        int pk_B_temp;
        uint q;
        uint q1;
        uint hcf;
        uint denominator;
        uint numerator;
        for(uint i=0; i<6; i++){
            pk_B_temp = pk_B[i];
            while(pk_B_temp<0){
                pk_B_temp = pk_B_temp + int(Publickey_p*2);
            }
            temp = mulmod(ciphertext, uint(pk_B_temp), Publickey_p*2);
            //q = div(temp, Publickey_p);
            //reduction of fraction
            denominator = Publickey_p;
            numerator = temp;
            while(denominator != 0){
                hcf = mulmod(1, numerator, denominator);
                numerator = denominator;
                denominator = hcf;
            }
            hcf = numerator;
            numerator = (temp/hcf)*1000;
            denominator = Publickey_p/hcf;
            //q = numerator / denominator;
            q = (numerator / denominator) / 1000;
            q1 = (((numerator / denominator) - (q*1000))*2) / 1000;
            temp = ((((numerator / denominator) - q*1000)*2 - q1*1000)*2) / 1000;
            for(uint j=0; j<3; j++){//SCARAB_T=3
                if(j==0){
                    temp = q;
                }
                else if(j==1){
                    temp = q1;
                }
                C[i][j] = encrypt_pk(int(temp));
                C[i][j] = mulmod(C[i][j], uint(pk_c[i]), Publickey_p);
            }
        }
        // Construct Hammingweight in H-matrix
        for(j=0; j<3; j++){//SCARAB_T=3
            for(i=1; i<=6; i++){
                for(uint k = (i < (2<<(0))) ? i : (2<<(0)); k >= 2; k--){//0=SCARAB_S-2
                    temp = mulmod(H[k-2][j], C[i-1][j], Publickey_p);
                    H[k-1][j] = addmod(H[k-1][j], temp, Publickey_p);
                }
                H[0][j] = addmod(H[0][j], C[i-1][j], Publickey_p*2);
            }
        }
        for(j=0; j<3; j++){//SCARAB_T=3
            H[2][j] = H[3][j];
        }
        for(j=1; j<3; j++){//SCARAB_T=3
            (H[j][j-1], H[1][j]) = (H[1][j], H[j][j-1]);
            (H[j][j], H[0][j]) = (H[0][j], H[j][j]);
        }
        // merge rows 0 and 3; 1 and 4
        for(i=0; i<2; i++){
            for(j=0; j<2; j++){//SCARAB_S=2
                H[i][i+j+1] = H[i+2][i+j+1];//SCARAB_S=2
            }
        }
        // carry save adder of rows 0,1,2 --> 0,1 (columnwise)
        for(j=0; j<3; j++){//SCARAB_T=3
            (H[3][j], H[4][j]) = e_full_add(H[0][j], H[1][j], H[2][j]);
        }
        // leftshift the row with the carry bits
        (H[3][2], H[0][2]) = (H[0][2], H[3][2]);//2 = SCARAB_T-1
        H[1][2] = encrypt_pk(0);//2 = SCARAB_T-1
        for(j=0; j<2; j++){//2 = SCARAB_T-1
            (H[3][j], H[0][j]) = (H[0][j], H[3][j]);
            (H[1][j], H[4][j+1]) = (H[4][j+1], H[1][j]);
        }
        // ripple-carry-add rows 0 and 1 --> 0 (LSB at SCARAB_T-1)
        (H[4][1], temp) = e_half_add(H[0][1], H[1][1]);//1 = SCARAB_T-2
        (H[4][0], temp) = e_full_add(H[0][0], H[1][0], temp);
        temp = addmod(H[4][0], H[4][1], Publickey_p);
        ciphertext = mulmod(1, ciphertext, 2);
        ciphertext = addmod(ciphertext, temp, Publickey_p);
        return ciphertext;
    }

    function e_encrypt_bits(int a) public returns(uint) {
        uint ciphertext;
        ciphertext = encrypt_pk(a);
        ciphertext = encrypt_pk(a);
        ciphertext = encrypt_pk(a);
        emit timeStamper(time, msg.sender, ciphertext);
        return ciphertext;
    }

    function encrypt_pk(int message) public view returns(uint) {
        int ciphertext;
        uint randNonce = 0;
        int exp_length_half = 2;
        int [2] memory poly_even;
        uint result;
        uint random = uint(keccak256(abi.encodePacked(now, msg.sender, randNonce))) % 4;
        poly_even[1] = (int(random) - exp_length_half)*2;
        poly_even[0] = message;
        ciphertext = poly_even[0] + poly_even[1]*alpha;
        while(ciphertext<=0){
            ciphertext = ciphertext + int(Publickey_p);
        }
        result = mulmod(uint(ciphertext), 1, Publickey_p);
        return result;
    }
}
