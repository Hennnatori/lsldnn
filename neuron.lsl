//定数
float NE = 2.718282;

//リストをindex単位で逆転させる
list nnRevList( list src, integer index ){
    
    list revList = [];
    
    integer i = llGetListLength( src );
    for( i ; i > 0 ; i = i - index ){
        
        revList = ( revList = [] ) + revList + llList2List( src, i - index , i - 1 );

    }
    
    return revList;
    
}


//Jsonの長さを取得
integer nnGetJsonLen( string jsonStr ){
    
    list jsonList = llJson2List( jsonStr );
    integer jsonLen = llGetListLength( jsonList );
    
    return jsonLen;
    
}


//Json入れ替え
string nnRevJson( string jsonStr ){
    
    string result = llList2Json( JSON_ARRAY, [] );
    
    integer i = nnGetJsonLen( jsonStr );
    for( i ; i >= 0 ; i-- ){
        
        result = llJsonSetValue( result, [JSON_APPEND], llJsonGetValue( jsonStr, [i] ) );
    }
    
    return result;
}


//Json配列の合計
float nnJsonSum( string jsonStr ){
    
    float result = 0.0;
    
    integer i = 0;
    for( i ; i < nnGetJsonLen( jsonStr ); i++ ){
        
        result = result + (float)llJsonGetValue( jsonStr, [i] );
    }
    
    return result;
}


//Json配列の最大値
float nnJsonMax( string jsonStr ){
    
    float result = 0.0;
    
    integer i = 0;
    for( i ; i < nnGetJsonLen( jsonStr ); i++ ){
        
        if( result < (float)llJsonGetValue( jsonStr, [i] ) ){
            
            result = (float)llJsonGetValue( jsonStr, [i] );
        }
    }
    
    return result;
}

//Json配列の最大値のIndex
integer nnJsonMaxIdx( string jsonStr ){
    
    integer result = 0;
    float max = 0.0;
    
    integer i = 0;
    for( i ; i < nnGetJsonLen( jsonStr ); i++ ){
        
        if( max < (float)llJsonGetValue( jsonStr, [i] ) ){
            
            result = i;
        }
    }
    
    return result;
}


//Json配列の入れ替え
string nnJsonTrans( string jsonStr ){
    
    string result = llList2Json( JSON_ARRAY, [] );
    
    integer i = 0;
    for( i ; i < nnGetJsonLen( jsonStr ); i++ ){
        
        integer j = 0;
        for( j ; j < nnGetJsonLen( jsonStr ); j++ ){
            
            result = llJsonSetValue( result, [JSON_APPEND], llJsonGetValue( jsonStr, [j, i] ) );
        }
    }
    
    return result;
}


//nの階乗
integer nnFact( integer n ){
    
    integer i = 1;
    integer factResult = 1;
    
    if( n == 0 ){
        
        return 1;
    }else{
        
        for( i ; i <= n ; i++){
            
            factResult = factResult * i;
        }
        
        return factResult;
    }
}


//xのn乗
float nnPow( float x, integer n ){
    
    integer i = 0;
    float powResult = 1.0;

    if( n == 0 ){
        
        return 1;
    }else{
        
        for(i; i < n ; i++){
            
            powResult = powResult * x;
        }
        
    }
    
    return powResult;
}


//Exp関数(注意:結果の収束を待たずに結果を出力するため引数が大きくなると誤差が拡大します)
//整数部と小数部分を分けて計算することである程度誤差を収束させています
float nnExp( float x ){
    
    //増やすと精度が上がるがSLの限界を超えて死ぬ
    integer LOOPCOUNT = 25;
    
    float expResult = 0.0;
    
    //整数と少数を分離
    integer e_a = (integer)llFloor(x);
    float e_b = x - e_a;
    
    //整数部分を計算
    expResult = nnPow(NE, e_a);
    
    //少数部分を計算
    integer i = 1;    
    for( i ; i <= LOOPCOUNT ; i++){
        
        expResult = expResult + nnPow(e_b, i) / nnFact(i);
    }
    
    return expResult;
}


//シグモイド関数(ゲインを設定できるよ)
float nnSigmoid( float x, float gain ){
    
    return 1.0 / (1.0 + nnExp( -gain * x ));
}


//シグモイド関数の偏導関数(ゲインを設定できるよ)
float nnSigmoidDar( float x, float gain ){
    
    float output = nnSigmoid( x, gain );
    return output * ( 1.0 - output );
}


//ReLU関数
float nnRelu( float x ){
    
    return x * ( x > 0 );
}


//ReLU関数の偏導関数
float nnReluDar( float x ){
    
    return 1.0 * ( x > 0 );
}


//softmax関数
string nnSoftmax( string jsonStr ){
    
    string result = llList2Json( JSON_ARRAY, [] );
    
    integer i = 0;
    for( i ; i < nnGetJsonLen( jsonStr ); i++ ){
        
        float exp = nnExp( (float)llJsonGetValue( jsonStr, [i] ) );
        result = llJsonSetValue( result, [JSON_APPEND], (string)exp );
    }
    
    float sum = nnJsonSum( result );
    integer j = 0;
    for( j ; j < nnGetJsonLen( jsonStr ); j++ ){
        
        float norm = (float)llJsonGetValue( result, [j] ) / sum;
        result = llJsonSetValue( result, [j], (string)norm );
    }
    
    return result;
}

//softmax関数の偏導関数
//入力と同じ数の次元数のベクトルが帰ってくるが使い方がわからない
string nnSoftmaxDar( string jsonStr ){
    
    string y = nnSoftmax( jsonStr );
    string result = llList2Json( JSON_ARRAY, [] );

    integer i = 0;
    integer j = 0;
    for( i ; i < nnGetJsonLen( y ); i++ ){
        
        string yy = llList2Json( JSON_ARRAY, [] );
        for( j = 0 ; j < nnGetJsonLen( y ); j++ ){
        
            float sum = -(float)llJsonGetValue( y, [i] ) * (float)llJsonGetValue( y, [j] );
            yy = llJsonSetValue( yy, [JSON_APPEND], (string)sum );
        }
        
        result = llJsonSetValue( result, [JSON_APPEND], yy );
    }
    
    for( i = 0 ; i < nnGetJsonLen( y ); i++ ){
        
        float dar = (float)llJsonGetValue( y, [i] ) * ( 1.0 - (float)llJsonGetValue( y, [i] ) );
        result = llJsonSetValue( result, [i, i], (string)dar );
    }
    
    return result;
}


//恒等関数
//入力結果はそのまま返すだけ回帰問題用
float nnIdentity( float x ){
    
    return x;
}


//恒等関数の偏導関数
//恒等関数の偏微分の計算結果を返す。
float nnIdentityDar( float x ){
    
    return 1.0;
}


//重み付き線総和
float nnSummation( list x, list weight, float bias ){
    
    integer i = 0;
    integer loopCount = 0;
    float linearSum = 0.0;
    
    if( llGetListLength( x ) < llGetListLength( weight ) ){
        
        loopCount = llGetListLength( x );
    }else{
        
        loopCount = llGetListLength( weight );
    }
       
    for( i ; i < loopCount ; i++ ){
        
        linearSum = linearSum + llList2Float( x, i ) * llList2Float( weight, i );
    }
    
    linearSum = linearSum + bias;
    
    return linearSum;
}


//重み付き線総和の偏導関数
//線総和を各重みで偏微分
list nnSumDarW( list x, list weight, float bias){
    
    return x;
}


//重み付き線総和の偏導関数
//線総和をバイアスで偏微分
float nnSumDarB( list x, list weight, float bias){
    
    return 1.0;
}


//重み付き線総和の偏導関数
//線総和を各入力で偏微分
list nnSumDarX( list x, list weight, float bias){
    
    return weight;
}


//二乗和誤差（SSE：Sum of Squared Error）
//yPred予測値yTrue正解値その差は誤差
float nnSseLoss( float yPred, float yTrue ){
    
    return 0.5 * (　( yPred - yTrue ) * ( yPred - yTrue )　);
}


//二乗和誤差（SSE：Sum of Squared Error）の偏微分関数
float nnSseLossDar( float yPred, float yTrue ){
    
    return yPred - yTrue;
}


//順伝播関数
string nnForwardProp( string model, list x, integer chcheMode ){

    //モデル
    string layers = llJsonGetValue( model, ["Layers"] );
    string weights = llJsonGetValue( model, ["Weights"] );
    string biases = llJsonGetValue( model, ["Biases"] );
    
    //出力用リスト
    string cachedSums = llList2Json( JSON_ARRAY, [] );
    string cachedOuts = llList2Json( JSON_ARRAY, [] );
    
    //入力層そのまま処理
    cachedOuts =　llJsonSetValue( cachedOuts, [JSON_APPEND], llList2Json( JSON_ARRAY, x ) );
    list nextX = x;
    
    //隠れ層～出力層レイヤー処理
    integer layer_i = 1; //入力層をスキップ
    for( layer_i ; layer_i < nnGetJsonLen( layers ) ; layer_i++ ){

        //レイヤー内リスト
        string sums = llList2Json( JSON_ARRAY, [] );
        string outs = llList2Json( JSON_ARRAY, [] );

        //各ノード処理
        integer node_i = 0;
        for( node_i ; node_i < (integer)llJsonGetValue( layers , [layer_i] ) ; node_i++ ){

            //入力層スキップのためのマジックナンバー"-1"
            list w = llJson2List( llJsonGetValue( weights, [layer_i - 1, node_i]) );
            float b = (float)llJsonGetValue( biases, [layer_i - 1, node_i] );

            //ノード合計
            float nodeSum = nnSummation( nextX, w, b );

            //ノード出力
            float nodeOut = 0.0;

            //出力層は活性化関数が違う
            if( layer_i < nnGetJsonLen( layers ) - 1 ){
                
                //ノード合計を活性化
                nodeOut = nnSigmoid( nodeSum, 1.0 );
            }else{
                
                //出力層はそのまま
                nodeOut = nnIdentity( nodeSum );
            }
            
            //ノード出力をレイヤー出力へ追加
            sums = llJsonSetValue( sums, [JSON_APPEND], (string)nodeSum );
            outs = llJsonSetValue( outs, [JSON_APPEND], (string)nodeOut );
        }

        //レイヤー出力をネットワーク出力へ追加
        cachedSums = llJsonSetValue( cachedSums, [JSON_APPEND], sums );
        cachedOuts = llJsonSetValue( cachedOuts, [JSON_APPEND], outs );
        
        //レイヤー出力を次の入力に
        nextX = llJson2List( outs );
        
    }
    
    //学習モード時は逆伝播用のデータを返す
    if( chcheMode ){

        return llList2Json( JSON_OBJECT, ["yPred", llJsonGetValue( cachedOuts, [nnGetJsonLen( cachedOuts ) - 1 ] ), "cachedOuts", cachedOuts, "cachedSums", cachedSums] );
    }else{
        
        return llList2Json( JSON_OBJECT, ["yPred", llJsonGetValue( cachedOuts, [nnGetJsonLen( cachedOuts ) - 1 ] ) ] );
    }
}


//逆伝播関数
string nnBackProp( string model, list yTrue, string cachedOut, string cachedSums ){
    
    //モデル
    string layers = llJsonGetValue( model, ["Layers"] );
    string weights = llJsonGetValue( model, ["Weights"] );
    string biases = llJsonGetValue( model, ["Biases"] );
    
    //ネットワーク全体勾配リスト
    string gradsW = llList2Json( JSON_ARRAY, [] );//重み勾配
    string gradsB = llList2Json( JSON_ARRAY, [] );//バイアス勾配
    string gradsX = llList2Json( JSON_ARRAY, [] );//入力勾配
    
    //入力層スキップ各レイヤー逆順処理
    integer layer_i = nnGetJsonLen( layers );
    for( layer_i ; layer_i > 1 ; layer_i-- ){
        
        //出力層フラグ
        integer isOutputLayer = layer_i == nnGetJsonLen( layers );
        
        //ノード勾配リスト
        string layerGradsW = llList2Json( JSON_ARRAY, [] );
        string layerGradsB = llList2Json( JSON_ARRAY, [] );
        string layerGradsX = llList2Json( JSON_ARRAY, [] );
        
        //誤差情報格納用
        list backErrors = [];
        
        if( isOutputLayer ){//出力層
            
            //予測値(cachedOutの最後の出力)
            list yPred = llJson2List( llJsonGetValue( cachedOut, [layer_i - 1] ) );
            
            //逆伝播する誤差情報
            integer output_i = 0;
            list be = [];
            for( output_i ; output_i < llGetListLength( yPred ) ; output_i++ ){
                
                float lossDar = nnSseLossDar( llList2Float( yPred, output_i ), llList2Float( yTrue, output_i ) );
                backErrors = ( backErrors = [] ) + backErrors + [ (float)lossDar ];
            }
        }else{//隠れ層
            
            //次の層への入力の偏微分係数
            backErrors = ( backErrors = [] ) + backErrors + llJson2List( llJsonGetValue( gradsX, [nnGetJsonLen( gradsX ) - 1] ) );//最後に追加された入力勾配
        }

        //ノード処理用リスト
        list nodeSum = llJson2List( llJsonGetValue( cachedSums, [layer_i - 2] ) );
        
        //ノード処理
        integer j = 0;
        for( j ; j < llGetListLength( nodeSum ) ; j++){
            
            //活性化関数を偏微分
            float activeDar = 0.0;
            if( isOutputLayer ){
                
                //出力層（恒等関数の微分）
                activeDar = nnIdentityDar( llList2Float( nodeSum, j ) );
            }else{
                
                //隠れ層（シグモイド関数の微分）
                activeDar = nnSigmoidDar( llList2Float( nodeSum, j ), 1.0 );

            }
            
            //線形和を重み／バイアス／入力で偏微分
            list w = llJson2List( llJsonGetValue( weights, [layer_i - 2, j]) );
            float b = (float)llJsonGetValue( biases, [layer_i - 2, j] );
            list x = llJson2List( llJsonGetValue( cachedOut, [layer_i - 2] ) );

            list sumDarW = nnSumDarW( x, w, b );
            float sumDarB = nnSumDarB( x, w, b );
            list sumDarX = nnSumDarX( x, w, b );

            //各重み／バイアス／各入力の勾配を計算
            float delta = llList2Float( backErrors, j ) * activeDar;
            
            //バイアスは一つだけ
            float gradB = delta * sumDarB;
            layerGradsB = llJsonSetValue( layerGradsB, [JSON_APPEND], (string)gradB );
            
            //重みと入力は前の層のノードの数だけある
            list nodeGradsW = [];
            integer k = 0;
            for( k ; k < llGetListLength( sumDarW ) ; k++ ){

                //重みは個別に
                float gradW = delta * llList2Float( sumDarW, k );
                nodeGradsW = ( nodeGradsW = [] ) + nodeGradsW + [ gradW ];
                
                //入力は接続するノード全てを合計
                float gradX = delta * llList2Float( sumDarX, k );
                if( j == 0 ){
                    
                    //リストに勾配を追加
                    layerGradsX = llJsonSetValue( layerGradsX, [JSON_APPEND], (string)gradX );
                }else{
                    
                    //追加した要素の加算
                    float nodeGradX = (float)llJsonGetValue(layerGradsX, [k]) + gradX;
                    layerGradsX = llJsonSetValue( layerGradsX, [k], (string)nodeGradX );
                }

            }
            layerGradsW = llJsonSetValue( layerGradsW, [JSON_APPEND], llList2Json( JSON_ARRAY, nodeGradsW ) );
        }
        
        //全体リストに追加
        gradsW = llJsonSetValue( gradsW, [JSON_APPEND], layerGradsW );
        gradsB = llJsonSetValue( gradsB, [JSON_APPEND], layerGradsB );
        gradsX = llJsonSetValue( gradsX, [JSON_APPEND], layerGradsX );
        
    }
    
    //逆順で処理したのでリストを反転
    gradsW = nnRevJson( gradsW );
    gradsB = nnRevJson( gradsB );
    
    //gradsXは最適化には不要
    return llList2Json( JSON_OBJECT, ["gradsW", gradsW, "gradsB", gradsB] );
}


//パラメーターアップデート
string nnUpdateParam( string model, string gradsW, string gradsB , float lr){
    
    //モデル
    string layers = llJsonGetValue( model, ["Layers"] );
    string weights = llJsonGetValue( model, ["Weights"] );
    string biases = llJsonGetValue( model, ["Biases"] );
    
    //ネットワーク全体用リスト
    string newWeights = llList2Json( JSON_ARRAY, [] );
    string newBiases = llList2Json( JSON_ARRAY, [] );
    
    //層処理ループ
    integer layer_i = 1;//入力層をスキップ
    for( layer_i ; layer_i < nnGetJsonLen( layers ) ; layer_i++ ){
        
        //レイヤー用リスト
        string layerW = llList2Json( JSON_ARRAY, [] );
        string layerB = llList2Json( JSON_ARRAY, [] );
        
        //ノード処理ループ
        integer node_i = 0;
        for( node_i ; node_i < (integer)llJsonGetValue( layers, [layer_i] ) ; node_i++ ){
            
            //バイアスパラメータの更新
            float b = (float)llJsonGetValue( biases, [layer_i - 1, node_i] );
            float gradB = (float)llJsonGetValue( gradsB, [layer_i - 1, node_i] );
            
            b = b - lr * gradB;
            
            layerB = llJsonSetValue( layerB, [JSON_APPEND], (string)b );
            
            //重みパラメータの更新
            list nodeWeights = llJson2List( llJsonGetValue( weights, [layer_i -1, node_i] ) );
            list nodeGradW = llJson2List( llJsonGetValue( gradsW, [layer_i -1, node_i] ) );
            list nodeW = [];
            
            //各重み処理
            integer w_i = 0;
            for( w_i ; w_i < llGetListLength( nodeWeights ) ; w_i++ ){
                float gradW = llList2Float( nodeGradW, w_i );
                float w = llList2Float( nodeWeights, w_i ) - lr * gradW;
                nodeW = ( nodeW = [] ) + nodeW + [ w ];
            }
            
            layerW = llJsonSetValue( layerW, [JSON_APPEND], llList2Json( JSON_ARRAY, nodeW ) );
            
        }
        
        newWeights = llJsonSetValue( newWeights, [JSON_APPEND], layerW );
        newBiases = llJsonSetValue( newBiases, [JSON_APPEND], layerB );
    }
    
    return llList2Json( JSON_OBJECT, [ "newWeights", newWeights, "newBiases", newBiases ] );
}


//モデル生成
//乱数が代入されます
string nnCreateModel( list src ){
    
    //Weight生成
    string networkWeight = llList2Json( JSON_ARRAY, []);
    integer network_i = 1;
    for( network_i ; network_i < llGetListLength( src ) ; network_i++ ){
        
        string layerWeight = llList2Json( JSON_ARRAY, []);
        integer layer_i = 0;
        for( layer_i ; layer_i < llList2Integer( src, network_i ) ; layer_i++ ){
            
            string nodeWeight = llList2Json( JSON_ARRAY, [] );
            integer node_i = 0;
            for( node_i ; node_i < llList2Integer( src, network_i - 1 ) ; node_i++ ){
                nodeWeight = llJsonSetValue( nodeWeight, [JSON_APPEND], (string)llFrand( 1.0 ));
            }
            
            layerWeight = llJsonSetValue( layerWeight, [JSON_APPEND], nodeWeight );
        }
        
        networkWeight = llJsonSetValue( networkWeight, [JSON_APPEND], layerWeight );
    }
    
    //bias生成
    string networkBias = llList2Json( JSON_ARRAY, []);
    integer network_j = 1;
    for( network_j ; network_j < llGetListLength( src ) ; network_j++ ){
        
        string layerBias = llList2Json( JSON_ARRAY, []);
        integer layer_j = 0;
        for( layer_j ; layer_j < llList2Integer( src, network_j ) ; layer_j++ ){
            
            layerBias = llJsonSetValue( layerBias, [JSON_APPEND], (string)llFrand( 1.0 ) );
        }
        
        networkBias = llJsonSetValue( networkBias, [JSON_APPEND], layerBias );
    }
    
    //レイヤーJSONに変形
    string layer = llList2Json( JSON_ARRAY, src );
    
    return llList2Json( JSON_OBJECT, ["Layers", layer, "Weights", networkWeight, "Biases", networkBias] );    
}


string ModelLayer = "";
string ModelWeight = "";
string ModelBias = "";
string Model = "";
    
default
{
    
    state_entry()
    {
//        ModelLayer = "[2, 3, 2, 1]";
        Model = nnCreateModel( [2, 3, 2, 1] );
    }

    touch_start(integer total_number)
    {

        //モデル(JSON)
//        string ModelLayer = "[2, 2, 2]";
//        string ModelWeight = "[[[0.15, 0.2], [0.25, 0.3]], [[0.4, 0.45], [0.5, 0.55]]]";
//        string ModelBias = "[[0.35, 0.35], [0.6, 0.6]]";
        
//        string Model = llList2Json( JSON_OBJECT, ["Layers", ModelLayer, "Weights", ModelWeight, "Biases", ModelBias] );
        
        //仮データ
        list trainX = [0.05, 0.1];
        list yTrue = [1.0];
        
            
        //順伝播
        string fProp = nnForwardProp( Model, trainX, TRUE );
        string yPred = llJsonGetValue( fProp, ["yPred"] );
        string cachedOuts = llJsonGetValue( fProp, ["cachedOuts"] );
        string cachedSums = llJsonGetValue( fProp, ["cachedSums"] );
//        llOwnerSay(fProp);
        
        //逆伝播
        string bProp = nnBackProp( Model, yTrue, cachedOuts, cachedSums );
        string gradsW = llJsonGetValue( bProp, ["gradsW"] );
        string gradsB = llJsonGetValue( bProp, ["gradsB"] );
//        llOwnerSay(bProp);
        
        //パラメタ更新
        string uPram = nnUpdateParam( Model, gradsW, gradsB, 0.1 );
        ModelWeight =llJsonGetValue( uPram, ["newWeights"] );
        ModelBias = llJsonGetValue( uPram, ["newBiases"] );
//        llOwnerSay((string)uPram);

        Model = llList2Json( JSON_OBJECT, ["Layers", ModelLayer, "Weights", ModelWeight, "Biases", ModelBias] );
        
        llSetText( "ディープニューラルネットワーク君\nUsed Memory:" + (string)llGetUsedMemory() + "Byte\n入力値:" + "[" + llDumpList2String(trainX,"|") + "]" + "\n予測値:" + yPred + "\n正解値:" + "[" + llDumpList2String(yTrue, "|") + "]", <0.0, 1.0, 0.0>, 1.0 );
     

    }
    
}
