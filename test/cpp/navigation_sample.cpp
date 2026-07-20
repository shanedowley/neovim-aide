#include <iostream>
#include <string>
#include <vector>

namespace Demo
{

class Logger
{
  public:
    Logger() = default;
    ~Logger() = default;

    void info(const std::string &message) { std::cout << "[INFO] " << message << std::endl; }

    void warning(const std::string &message) { std::cout << "[WARN] " << message << std::endl; }

  private:
    int level_ = 0;
};

class BankAccount
{
  public:
    BankAccount(std::string owner, double balance) : owner_(std::move(owner)), balance_(balance) {}

    void deposit(double amount)
    {
        balance_ += amount;
        logger_.info("Deposit completed");
    }

    bool withdraw(double amount)
    {
        if (amount > balance_)
        {
            logger_.warning("Insufficient funds");
            return false;
        }

        balance_ -= amount;
        return true;
    }

    double balance() const { return balance_; }

  private:
    std::string owner_;
    double balance_;
    Logger logger_;
};

struct Point
{
    int x;
    int y;

    void translate(int dx, int dy)
    {
        x += dx;
        y += dy;
    }
};

int factorial(int n)
{
    if (n <= 1)
    {
        return 1;
    }

    return n * factorial(n - 1);
}

void printAccounts(const std::vector<BankAccount> &accounts)
{
    std::cout << "Account count: " << accounts.size() << std::endl;
}

} // namespace Demo

int main()
{
    Demo::BankAccount account("Alice", 100.0);

    account.deposit(50.0);
    account.withdraw(25.0);

    Demo::Point point{10, 20};
    point.translate(5, -2);

    std::cout << Demo::factorial(5) << std::endl;

    return 0;
}
