#include <map>
#include <string>

class Test {
public:
  Test();
  ~Test() = default;

  void increase(std::string tag);
  void decrease(std::string tag);

  std::map<std::string, int *> tmap;
  int count;
}