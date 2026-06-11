/// 미디에이션 워터폴 추적 이벤트. SDK가 우선순위 순서대로 각 네트워크를
/// 시도할 때 Mediated* 서피스에서 방출된다. `ExelBidSDK.WaterfallEvent`를
/// 따르며 `WaterfallEventMapper`가 생성한 `{"type": ...}` 맵을 디코딩한다.
sealed class WaterfallEvent {
  const WaterfallEvent();

  factory WaterfallEvent.fromMap(Map<Object?, Object?> map) {
    final type = map['type'] as String?;
    switch (type) {
      case 'fetching':
        return const WaterfallFetching();
      case 'fetched':
        final networks = (map['networks'] as List?)
                ?.map((e) => e as String)
                .toList(growable: false) ??
            const <String>[];
        return WaterfallFetched(networks);
      case 'trying':
        return WaterfallTrying(
          network: map['network'] as String? ?? '',
          unitId: map['unitId'] as String? ?? '',
          position: map['position'] as int? ?? 0,
          total: map['total'] as int? ?? 0,
        );
      case 'won':
        return WaterfallWon(
          network: map['network'] as String? ?? '',
          position: map['position'] as int? ?? 0,
          latencyMs: map['latencyMs'] as int? ?? 0,
        );
      case 'lost':
        return WaterfallLost(
          network: map['network'] as String? ?? '',
          position: map['position'] as int? ?? 0,
          reason: map['reason'] as String? ?? '',
        );
      case 'noFill':
        return const WaterfallNoFill();
      default:
        return WaterfallUnknown(type ?? 'unknown');
    }
  }

  /// 네이티브 데모의 `WaterfallFormatter`와 일치하는, 로그에 적합한 한 줄
  /// 형태로 렌더링한다.
  String format();
}

class WaterfallFetching extends WaterfallEvent {
  const WaterfallFetching();

  @override
  String format() => 'fetching…';
}

class WaterfallFetched extends WaterfallEvent {
  const WaterfallFetched(this.networks);

  final List<String> networks;

  @override
  String format() => 'fetched: [${networks.join(', ')}]';
}

class WaterfallTrying extends WaterfallEvent {
  const WaterfallTrying({
    required this.network,
    required this.unitId,
    required this.position,
    required this.total,
  });

  final String network;
  final String unitId;
  final int position;
  final int total;

  @override
  String format() => '$position/$total trying → $network';
}

class WaterfallWon extends WaterfallEvent {
  const WaterfallWon({
    required this.network,
    required this.position,
    required this.latencyMs,
  });

  final String network;
  final int position;
  final int latencyMs;

  @override
  String format() => 'won: $network (${latencyMs}ms)';
}

class WaterfallLost extends WaterfallEvent {
  const WaterfallLost({
    required this.network,
    required this.position,
    required this.reason,
  });

  final String network;
  final int position;
  final String reason;

  @override
  String format() => 'lost: $network ($reason)';
}

class WaterfallNoFill extends WaterfallEvent {
  const WaterfallNoFill();

  @override
  String format() => 'noFill — all networks failed';
}

class WaterfallUnknown extends WaterfallEvent {
  const WaterfallUnknown(this.type);

  final String type;

  @override
  String format() => 'unknown: $type';
}
