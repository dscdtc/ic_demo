import Int "mo:base/Int";
import Array "mo:base/Array";

actor {
    private func quicksort (
        arr:[var Int],
        leftValue: Int,
        rightValue: Int,
    ) {
        if (leftValue < rightValue) {
        var i = leftValue;
        var j = rightValue;
        var swap = arr[0];
        let pivot = arr[Int.abs(leftValue + rightValue)/2];
        while (i<=j){
            while (arr[Int.abs(i)] < pivot) {
                i += 1;
            };
            while (arr[Int.abs(j)] > pivot){
                j -= 1;
            };
            if (i<=j) {
                let s = arr[Int.abs(i)];
                arr[Int.abs(i)] := arr[Int.abs(j)];
                arr[Int.abs(j)] := s;
                i+=1;
                j-=1;
            };
        };
        if(leftValue < j) {
            quicksort(arr, leftValue, j);
        };
        if (i < rightValue){
            quicksort(arr, i, rightValue);
        };
        };
    };

    public func qSort(arr:[Int]) : async [Int] {
        var newArr:[var Int] = Array.thaw(arr);
        quicksort(newArr,0,newArr.size()-1);
        Array.freeze(newArr)
    };
    public func greet(name : Text) : async Text {
        return "Hello, " # name # "!";
    };
};
