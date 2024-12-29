<img src="https://github.com/phosphor-icons/phosphor-elm/blob/master/meta/phosphor-mark-tight-black.png?raw=true" width="128" align="right" />

# phosphor-elm

Phosphor is a flexible icon family for interfaces, diagrams, presentations — whatever, really. Explore all our icons at [phosphoricons.com](https://phosphoricons.com).

This implementation is inspired by [elm-feather](https://package.elm-lang.org/packages/1602/elm-feather/latest).

[![GitHub stars](https://img.shields.io/github/stars/phosphor-icons/phosphor-elm?style=flat-square&label=Star)](https://github.com/phosphor-icons/phosphor-elm)
[![GitHub forks](https://img.shields.io/github/forks/phosphor-icons/phosphor-elm?style=flat-square&label=Fork)](https://github.com/phosphor-icons/phosphor-elm/fork)
[![GitHub watchers](https://img.shields.io/github/watchers/phosphor-icons/phosphor-elm?style=flat-square&label=Watch)](https://github.com/phosphor-icons/phosphor-elm)
[![Follow on GitHub](https://img.shields.io/github/followers/rektdeckard?style=flat-square&label=Follow)](https://github.com/rektdeckard)

## Installation

```bash
elm install phosphor-icons/phosphor-elm
```

## Usage

All icons have six weights; `Regular`, `Thin`, `Light`, `Bold`, `Fill`, and `Duotone`. Rendering an icon requires just a template and a weight:

```elm
import Phosphor exposing (IconWeight(..))

-- Within your view:
Phosphor.checks Bold
    |> Phosphor.toHtml []
```

### Styling

Icons behave as text, inheriting the `color` and `font-size` from their parent. Further styling can be applied with the helpers `withSize`, `withSizeUnit`, and `withClass`.

```elm
Phosphor.cloud Duotone
    |> withSize 24
    |> withSizeUnit "px"
    |> withClass "custom-icon"
    |> toHtml []
```

By default all icons render at `1em` with the class `ph-icon`.

<!-- BEGIN_LINKS -->
## Our Related Projects

- [@phosphor-icons/homepage](https://github.com/phosphor-icons/homepage) ▲ Phosphor homepage and general info
- [@phosphor-icons/core](https://github.com/phosphor-icons/core) ▲ Phosphor icon assets and catalog
- [@phosphor-icons/react](https://github.com/phosphor-icons/react) ▲ Phosphor icon component library for React
- [@phosphor-icons/web](https://github.com/phosphor-icons/web) ▲ Phosphor icons for Vanilla JS
- [@phosphor-icons/vue](https://github.com/phosphor-icons/vue) ▲ Phosphor icon component library for Vue
- [@phosphor-icons/swift](https://github.com/phosphor-icons/swift) ▲ Phosphor icon component library for SwiftUI
- [@phosphor-icons/elm](https://github.com/phosphor-icons/phosphor-elm) ▲ Phosphor icons for Elm
- [@phosphor-icons/flutter](https://github.com/phosphor-icons/flutter) ▲ Phosphor IconData library for Flutter
- [@phosphor-icons/webcomponents](https://github.com/phosphor-icons/webcomponents) ▲ Phosphor icons as Web Components
- [@phosphor-icons/figma](https://github.com/phosphor-icons/figma) ▲ Phosphor icons Figma plugin
- [@phosphor-icons/sketch](https://github.com/phosphor-icons/sketch) ▲ Phosphor icons Sketch plugin
- [@phosphor-icons/pack](https://github.com/phosphor-icons/pack) ▲ Phosphor web font stripper to generate minimal icon bundles
- [@phosphor-icons/theme](https://github.com/phosphor-icons/theme) ▲ A VS Code (and other IDE) theme with the Phosphor color palette

## Community Projects

- [phosphor-react-native](https://github.com/duongdev/phosphor-react-native) ▲ Phosphor icon component library for React Native
- [phosphor-svelte](https://github.com/haruaki07/phosphor-svelte) ▲ Phosphor icons for Svelte apps
- [phosphor-r](https://github.com/dreamRs/phosphoricons) ▲ Phosphor icon wrapper for R documents and applications
- [blade-phosphor-icons](https://github.com/codeat3/blade-phosphor-icons) ▲ Phosphor icons in your Laravel Blade views
- [wireui/phosphoricons](https://github.com/wireui/phosphoricons) ▲ Phosphor icons for Laravel
- [phosphor-css](https://github.com/lucagoslar/phosphor-css) ▲ CSS wrapper for Phosphor SVG icons
- [ruby-phosphor-icons](https://github.com/maful/ruby-phosphor-icons) ▲ Phosphor icons for Ruby and Rails applications
- [eleventy-plugin-phosphoricons](https://github.com/reatlat/eleventy-plugin-phosphoricons) ▲ An Eleventy plugin for add shortcode, allows Phosphor icons to be embedded as inline svg into templates
- [phosphor-leptos](https://github.com/SorenHolstHansen/phosphor-leptos) ▲ Phosphor icon component library for Leptos apps (rust)
- [wordpress-phosphor-icons-block](https://github.com/robruiz/phosphor-icons-block) ▲ Phosphor icon block for use in WordPress v5.8+
- [ember-phosphor-icons](https://github.com/IgnaceMaes/ember-phosphor-icons) ▲ Phosphor icons for Ember apps

If you've made a port of Phosphor and you want to see it here, just open a PR [here](https://github.com/phosphor-icons/homepage)!

## License

MIT © [Phosphor Icons](https://github.com/phosphor-icons)
<!-- END_LINKS -->
