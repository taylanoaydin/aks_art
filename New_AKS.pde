import java.math.*;
int[] carmichaels = {1729, 2821, 8911, 15841};

float randOne = random(0,255);
float randTwo = random(0,255);
float radiusConstant = 28.5;

void setup() {
  size(900,900);
  background(0);
}

void draw(){
  
  boolean rgb1;
  boolean rgb2;
  float rand = random(1);
  
  //determine which two of the RGB values are constant
  if(rand < 0.33){
    rgb1 = true;
    rgb2 = true;
  }
  else if(rand < 0.67){
    rgb1 = true;
    rgb2 = false;
  }
  else{
    rgb1 = false;
    rgb2 = false;
  }
  
  int start = 8; //initial input
  
  for(int circle = 4; circle < 15; circle++){
    pushMatrix();
    translate(width/2,height/2 - 25);
    
    float r = circle*radiusConstant;
    float x = circle*radiusConstant;
    float y = sqrt(pow(r,2) - pow(x,2));
    
    float theSize = pow(2,(circle-1)); //size of the number set that has "circle" number of binary digits
    float increment = circle*radiusConstant*4/theSize;
    boolean still = true; //to decide when to end the circle
    boolean turned = false; //is true when the left end of the circle is reached

    
    if(rgb1 && rgb2){
      stroke(randOne, randTwo, map(circle, 4, 15, 0, 255));
    }
    else if(rgb1){
      stroke(randOne, map(circle, 4, 15, 0, 255), randTwo);
    }
    else{
      stroke(map(circle, 4, 15, 0, 255), randOne, randTwo);
    }
    
    beginShape();
    noFill();
    while(still){
      if(toBinary(start).size() == circle){
        if(isPrime(start)){
          float tempX = x;
          float tempY = y;
          for(int ab = 0; ab < (int) random(3,6); ab++){ //bumps
            tempX = tempX + randomGaussian()*3;
            tempY = tempY + randomGaussian()*3;
            curveVertex(tempX, tempY);
          }
          println(start);
        }
        else{ //no bump if it is a composite number
          curveVertex(x,y);
        }

        if(turned){ //lower half of the circle
          x += increment;
          y = -sqrt(pow(r,2) - pow(x,2));
        }
        else{ //upper half of the circle
          x -= increment;
          y = sqrt(pow(r,2) - pow(x,2));
          if(x == -circle*radiusConstant){
            turned = true;
          }
        }
        start++;
      }
      else{ //ends the circle
        endShape();
        println("change");
        still = false;
      }
    }
    popMatrix();
    
  }
  
  noLoop();
}

boolean isPrime(int n){
  
  for(int index = 1; index < carmichaels.length; index++){
    if(n == carmichaels[index]){
      return false;
    }
  }
  
  int res = (int) log2(n);
  for(int i = 2; i <= res; i++){
    double root = pow(n,(1/(float)i));
    double roundedRoot = (double) ((int) (root + 0.5));
    float difference = (float) (roundedRoot - root);
    if(abs(difference) < 0.0000001){
      return false;
    }
  }

  
  int r = 3;

  for(long i = 1; i <= r; i++){ 
    long test = gcd(i,n);
    if(test > 1 && test < n){
      return false;
    }
  }
  
  if(n <= r){
    return true;
  }
  
  long restraint = (long) (sqrt((float) euler(r)) * log10(n));
  

  
  for(int a = 1; a <= restraint; a++){  
    Polynomial testPol = new Polynomial(a);
    
    Polynomial storage = new Polynomial(1, false);
    ArrayList<Integer> binary = toBinary(n);
    for(int bin = 0; bin < binary.size(); bin++){
       if(binary.get(bin) == 1){
         for(int degree = 0; degree < bin; degree++){
             testPol = testPol.multiply(testPol, testPol);
             testPol = testPol.polMod(n,r);
          }

          storage = storage.multiply(testPol,storage);
          storage = storage.polMod(n,r);
          
          testPol = new Polynomial(a);
       }
    }
     
    
     
     Polynomial sub = new Polynomial(a, n);
     storage.subtract(sub);
     storage = storage.polMod(n, r);
     
    
     
      for(int all = 1; all < storage.terms.size(); all++){
        if(storage.terms.get(all) % n != 0){
          return false;
        }
      }
    

    
  }

 
  return true;
  
}
  
long euler(long ar){ 
  long result = ar;
    for (long i = 2; i * i <= ar; i++) {
        if(ar % i == 0) {
            while(ar % i == 0){
                ar /= i;
            }
            result -= result / i;
        }
    }
    if(ar > 1){
        result -= result / ar;
    }
    return result;
}

long gcd(long a, long b) {  //https://cp-algorithms.com/algebra/phi-function.html
  long t;

  while (b != 0) {
    t = b;
    b = a % b;
    a = t;
  }
 
   return a;
}

float log10 (long x) {
  return (log(x) / log(10));
}

float log2 (long x) {
  return (log(x) / log(2));
}

ArrayList<Integer> toBinary(int x){
  ArrayList<Integer> binary = new ArrayList<Integer>();
  int remainder;
  while(x > 0){
    remainder = x % 2;
    binary.add(remainder);
    x = x/2;
  }
  return binary;
}





class Polynomial{
  
  ArrayList<Integer> terms;
  
  Polynomial(int a){
    terms = new ArrayList<Integer>();
    terms.add(a);
    terms.add(1);
  }
  
  Polynomial(int size, boolean fill){
    terms = new ArrayList<Integer>();
    if(fill){
      for(int a = 0; a < size; a++){
        terms.add(0);
      }
    }
    else{
      for(int a = 0; a < 1; a++){
        terms.add(1);
      }
    }
  }
  
  Polynomial(int a, int n){
    terms = new ArrayList<Integer>();
    terms.add(a);
    for(int i = 1; i< n; i++){
      terms.add(0);
    }
    terms.add(1);
  }
  
  
  
  
  Polynomial multiply(Polynomial first, Polynomial second){
    int degree = first.terms.size() + second.terms.size() - 1;
    Polynomial result = new Polynomial(degree, true);
    int resultingIndex;
    int temp;
    
    for(int a = 0; a < first.terms.size(); a++){
      for(int b = 0; b < second.terms.size(); b++){
        if(!(first.terms.get(a) == 0 || second.terms.get(b) == 0)){
          resultingIndex = a + b;
          temp = first.terms.get(a) * second.terms.get(b);
          temp = temp + result.terms.get(resultingIndex);
          result.terms.set(resultingIndex, temp);
        }
      }
    }
    
    return result;
  }
  
  Polynomial polMod(int n, int r){
    int newInd;
    int coef;
    Polynomial result = new Polynomial(r, true);
    
    for(int i = 0; i < this.terms.size(); i++){
      newInd = i % r;
      coef = this.terms.get(i) % n;
      coef = result.terms.get(newInd) + coef;
      result.terms.set(newInd, coef);
    }

    return result;
  }
  
/*  void simplify(){
    boolean zero = false;
    int mag = this.terms.size();
    if(this.terms.get(mag-1) == 0){
      zero = true;
      this.terms.remove(mag-1);
      mag--;
    }
    while(zero){
      if(this.terms.get(mag-1) == 0){
        this.terms.remove(mag-1);
        mag--;
      }
      else{
        zero = false;
      }
      if(mag - 1 == -1){
        zero = false;
      }
    }
  } */
  
  void subtract(Polynomial sub){
    while(sub.terms.size() > this.terms.size()){
      this.terms.add(0);
    }
    while(this.terms.size() > sub.terms.size()){
      sub.terms.add(0);
    }
    for(int i = 0; i < this.terms.size(); i++){
      int result = this.terms.get(i) - sub.terms.get(i);
      this.terms.set(i, result);
    }
  }

}
