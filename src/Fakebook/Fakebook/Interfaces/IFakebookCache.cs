namespace Fakebook.Interfaces;

public interface IFakebookCache
{
    public T Get<T>(string key);
    public T Set<T>(string key, T value);
    public bool Exists(string key);
    public void Remove(string key);
}

