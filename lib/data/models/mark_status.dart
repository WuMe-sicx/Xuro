enum MarkStatus {
  wantToListen('想听'),
  listening('在听'),
  listened('听过'),
  relistening('重听'),
  onHold('搁置');

  final String label;
  const MarkStatus(this.label);
}
