enum DbCollections {
  users('users'),
  rooms('rooms');

  final String key;
  const DbCollections(this.key);
}
