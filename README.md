# Glimesh Mobile App

Glimesh is a next generation streaming platform built by the community, for the community.
Our platform focuses on increasing discoverability for content creators and implementing the
latest in streaming technology to level the playing field. We understand the importance of
interaction between content creators and their fans, and we’re dedicated to innovating new
ways to bring communities closer together.

This repository houses the Glimesh Mobile App.

### Contributing
1. [Fork it!](http://github.com/Glimesh/glimesh_app/fork)
2. Create your feature branch (`git checkout -b feature/my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin feature/my-new-feature`)
5. Create new Pull Request

## Development Installation

These instructions serve as a reference for getting Glimesh running whatever type of local machine you have for development. Some instructions may be specific to various distributions, substitution may be required with the correct procedure for your configuration.

### General Dependencies

You will need the following tools to clone, build, and run Glimesh:

- **git**: Source control
- **flutter**: Mobile App Framework

You may need to translate these exact dependencies into their appropriate names for your OS distribution.

## Apple M1 Notes
*Note, this may not be required if you use Homebrew to install a newer version of Ruby.*
You may need to install the pods using slightly different methods:
```sh
cd ios
arch -x86_64 pod install
```

## Testing

```sh
flutter test
```

## Help
If you need help with anything, please feel free to open [a GitHub Issue](https://github.com/Glimesh/glimesh_app/issues/new).

## Security Policy
Our security policy can be found in [SECURITY.md](SECURITY.md).

## License
The Glimesh Mobile App is licensed under the [MIT License](LICENSE.md).