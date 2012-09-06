class RandArray {
// creates a virtual bucket of numbers that is sampled without replacement
  ArrayList theArrayList = new ArrayList();
  RandArray(float[] _theArray) {
    for (int i = 0; i< _theArray.length; i++) {
     theArrayList.add(new Float(_theArray[i]));
    }
  }

  float pick() {
    int pickIdx=round(random(0,theArrayList.size()-1));
    Float pickNumFloat =  (Float) theArrayList.get(pickIdx);
    float pickNum = pickNumFloat.floatValue();
    theArrayList.remove(pickIdx);
    return pickNum;
  }
}
