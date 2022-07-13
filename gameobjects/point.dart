
class Point {
  int x;
  int y;

  Point(this.x, this.y);

  Point clone() {
    return Point(x,y);
  }

  Point operator +(Point other) {
    return Point(this.x+other.x, this.y+other.y);
  }

  Point operator -(Point other) {
    return Point(this.x-other.x, this.y-other.y);
  }
}