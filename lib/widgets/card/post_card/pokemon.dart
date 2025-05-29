import 'package:dart_mappable/dart_mappable.dart';
import 'package:tsdm_client/extensions/universal_html.dart';
import 'package:universal_html/html.dart' as uh;

part 'pokemon.mapper.dart';

/// Pokemon status in the current post floor..
@MappableClass()
final class PostFloorPokemon with PostFloorPokemonMappable {
  /// Constructor
  const PostFloorPokemon(this.primaryPokemon, this.otherPokemon);

  /// The pokemon at the first place.
  final PokemonInfo primaryPokemon;

  /// All other pokemon shown.
  final List<PokemonInfo>? otherPokemon;

  /// Build instance from `div.tsdm_pokemon` node.
  static PostFloorPokemon? fromDiv(uh.Element element) {
    // showWindow('pokemon','plugin.php?id=pokemon:pokemon&index=ajax_pm&petid=${ID}&action=show&cshu=2')
    final firstDetailInfo = element
        .querySelector('a:nth-child(1)')
        ?.attributes['onclick']
        ?.split("'")
        .elementAtOrNull(3);
    final firstImage = element.querySelector('a:nth-child(1) > img')?.imageUrl();
    final firstName = element.querySelector('p:nth-child(2)')?.innerText;
    final PokemonInfo? firstPokemon;
    if (firstDetailInfo != null && firstImage != null && firstName != null) {
      firstPokemon = PokemonInfo(name: firstName, image: firstImage, detailInfo: firstDetailInfo);
    } else {
      firstPokemon = null;
    }

    final others = element
        .querySelectorAll('p:nth-child(3) > a')
        .map((e) {
          final detailIngo = e.attributes['onclick']?.split("'").elementAtOrNull(3);
          final image = e.querySelector('img')?.imageUrl();
          final name = e.querySelector('img')?.attributes['title'];
          if (detailIngo != null && image != null && name != null) {
            return PokemonInfo(name: name, image: image, detailInfo: detailIngo);
          }
          return null;
        })
        .whereType<PokemonInfo>()
        .toList();

    if (firstPokemon == null) {
      return null;
    }

    return PostFloorPokemon(firstPokemon, others);
  }
}

/// Info about a single pokemon
@MappableClass()
final class PokemonInfo with PokemonInfoMappable {
  /// Constructor.
  const PokemonInfo({required this.name, required this.image, required this.detailInfo});

  /// Pokemon name.
  final String name;

  /// Url of pokemon appearance image.
  final String image;

  /// Url of detail info dialog.
  final String detailInfo;
}
