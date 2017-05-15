# PgTrgm

Other Ruby trigram similarity libraries don't give the same results as postgres. This one does.

## Usage

```ruby
PgTrgm.similarity('he is genius', 'he is very genius')
```

## History

* Discovered that https://github.com/milk1000cc/trigram didn't give the same results as https://www.postgresql.org/docs/9.6/static/pgtrgm.html
* Found https://gist.github.com/komasaru/41b0c93e264be75eabfa and modified until it passed tests

## Known issues

* Doesn't handle accented characters well

## Copyright

2017 Faraday
