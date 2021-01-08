# include <iostream >
using namespace std ;

void printQS (int* arr , int size ) {
    for (int i = 0; i < size ; i ++) cout << arr [ i ] <<" ";
    cout << endl ;
}

int Partition (int* start , int low , int high ) {
    int pivot = start [ high ];
    int l = low - 1;
    for ( int i = low ; i < high ; i ++) {
        if( start[ i ] < pivot ) {
            l ++;
            swap ( start [ l ] , start [ i ]) ;
        }
    }
    swap ( start [ high ] , start [ l + 1]) ;
    return l + 1;
}

void QuickSort (int* arr , int low , int high , int size ) {
    if( low < high ) {
        printQS ( arr , size ) ;
        int t = Partition ( arr , low , high ) ;
        cout << " partition : " << t << " low: "<< low << " high : " << high << endl ;
        QuickSort ( arr , low , t - 1 , size ) ;
        QuickSort ( arr , t + 1 , high , size ) ;
    }
}

int main () {
    int array [] = {20 ,19 ,18 ,17 ,16 ,15 ,14 ,13 ,12 ,11 ,10 ,9 ,8 ,7 ,6 ,5 ,4 ,3 ,2 ,1};
    QuickSort ( array , 0 , 19 , 20) ;
    printQS ( array , 20 ) ;
}