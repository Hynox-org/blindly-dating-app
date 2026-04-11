import sys

def check_braces(filename):
    with open(filename, 'r', encoding='utf-8') as f:
        content = f.read()
    
    stack = []
    line_num = 1
    col_num = 1
    
    for i, char in enumerate(content):
        if char == '\n':
            line_num += 1
            col_num = 1
            continue
            
        if char == '{':
            stack.append(('{', line_num, col_num))
        elif char == '}':
            if not stack:
                print(f"Extra closing brace at line {line_num}, col {col_num}")
                return
            stack.pop()
        col_num += 1
            
    if stack:
        for char, line, col in stack:
            print(f"Unmatched opening brace at line {line}, col {col}")
    else:
        print("Braces are balanced")

if __name__ == "__main__":
    check_braces(sys.argv[1])
