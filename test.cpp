
#include "test.h"

void Test::Test()
    : count(0)
{
    tmap["test1"] = new int(count++);
    tmap["test2"] = new int(count++);
    tmap["test3"] = new int(count++);
}

void Test::increase(std::string tag)
{
    tmap[tag] = new int(count++);
}

void Test::decrease(std::string tag)
{
    tmap.erase(tag);
}