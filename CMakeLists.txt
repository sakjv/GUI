cmake_minimum_required(VERSION 3.10)
project(GUI)

set(CMAKE_CXX_STANDARD 17)

add_executable(gui src/main.cpp src/gui.cpp)

target_include_directories(gui PRIVATE include)

target_link_libraries(gui user32 comctl32)

# For static linking
set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} /MT")