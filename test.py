# if height is <0, print it upside down
def print_tree(height):
    for i in range(height):
        print(' ' * (height - i - 1) + '*' * (2 * i + 1))
    print(' ' * (height - 1) + '|')

def main():
    while True:
        try:
            height = int(input("Enter tree height (or 0 to quit): "))
            if height == 0:
                break
            if height < 0:
                print("Please enter a positive number")
                continue
            print_tree(height)
        except ValueError:
            print("Please enter a valid number")

if __name__ == "__main__":
    main()
