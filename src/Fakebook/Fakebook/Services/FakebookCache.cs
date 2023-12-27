using Fakebook.Interfaces;
using Microsoft.Extensions.Caching.Distributed;
using System.Text.Json;

namespace Fakebook.Services;

public class FakebookCache : IFakebookCache
{
    private readonly IDistributedCache _cache;
    private readonly ILogger _logger;

    public FakebookCache(IDistributedCache redis, ILogger<FakebookCache> logger)
    {
        _cache = redis;
        _logger = logger;
    }

    public T Get<T>(string key)
    {
        var value = _cache.GetString(key);

        if(value is not null)
        {
            _logger.LogInformation($"Cache hit for '{key}'");
            return JsonSerializer.Deserialize<T>(value);
        }

        return default(T);
    }

    public T Set<T>(string key, T value)
    {
        if(Exists(key))
        {
            _logger.LogInformation($"Key '{key}' already exists. Refreshing the entry instead of adding");
            _cache.Refresh(key);
        } 
        else
        {
            _logger.LogInformation($"Caching key '{key}'");
            _cache.SetString(key, JsonSerializer.Serialize(value));
        }

        return Get<T>(key);
    }

    public bool Exists(string key)
    {
        return _cache.GetString(key) is not null;
    }

    public void Remove(string key)
    {
        _logger.LogInformation($"Removing key '{key}'");
        _cache.Remove(key);
    }
}

