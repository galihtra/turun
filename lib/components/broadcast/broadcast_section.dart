import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:turun/components/broadcast/broadcast_card.dart';
import 'package:turun/data/providers/broadcast/broadcast_provider.dart';

/// A section widget that displays the top broadcast if available
/// Use this in your home page or dashboard to show announcements
class BroadcastSection extends StatelessWidget {
  const BroadcastSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<BroadcastProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const SizedBox.shrink(); // Don't show loading state
        }

        final broadcast = provider.topBroadcast;
        if (broadcast == null) {
          return const SizedBox.shrink();
        }

        return BroadcastCard(
          broadcast: broadcast,
          onView: () => provider.viewBroadcast(broadcast.id),
          onAction: () => provider.onBroadcastAction(broadcast),
          onDismiss: () => provider.dismissBroadcast(broadcast.id),
        );
      },
    );
  }
}

/// A widget that shows all active broadcasts as a vertical list
class BroadcastList extends StatelessWidget {
  const BroadcastList({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<BroadcastProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (provider.broadcasts.isEmpty) {
          return const SizedBox.shrink();
        }

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.zero,
          itemCount: provider.broadcasts.length,
          itemBuilder: (context, index) {
            final broadcast = provider.broadcasts[index];
            return BroadcastCard(
              broadcast: broadcast,
              onView: () => provider.viewBroadcast(broadcast.id),
              onAction: () => provider.onBroadcastAction(broadcast),
              onDismiss: () => provider.dismissBroadcast(broadcast.id),
            );
          },
        );
      },
    );
  }
}

/// A horizontal scrollable carousel for broadcasts
class BroadcastCarousel extends StatelessWidget {
  const BroadcastCarousel({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<BroadcastProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading || provider.broadcasts.isEmpty) {
          return const SizedBox.shrink();
        }

        return SizedBox(
          height: 180,
          child: PageView.builder(
            controller: PageController(viewportFraction: 0.92),
            itemCount: provider.broadcasts.length,
            itemBuilder: (context, index) {
              final broadcast = provider.broadcasts[index];
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: BroadcastCard(
                  broadcast: broadcast,
                  onView: () => provider.viewBroadcast(broadcast.id),
                  onAction: () => provider.onBroadcastAction(broadcast),
                  onDismiss: () => provider.dismissBroadcast(broadcast.id),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

/// A compact banner that can be shown at the top of any screen
class BroadcastTopBanner extends StatelessWidget {
  const BroadcastTopBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<BroadcastProvider>(
      builder: (context, provider, child) {
        final broadcast = provider.topBroadcast;
        if (broadcast == null) {
          return const SizedBox.shrink();
        }

        return BroadcastBanner(
          broadcast: broadcast,
          onTap: () => provider.onBroadcastAction(broadcast),
          onDismiss: () => provider.dismissBroadcast(broadcast.id),
        );
      },
    );
  }
}

/// Modal bottom sheet to show broadcast details
class BroadcastModal extends StatelessWidget {
  final Function()? onClose;

  const BroadcastModal({super.key, this.onClose});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const BroadcastModal(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<BroadcastProvider>(
      builder: (context, provider, child) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          builder: (context, scrollController) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                children: [
                  // Handle
                  Container(
                    margin: const EdgeInsets.only(top: 12, bottom: 8),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  
                  // Header
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Announcements',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () {
                            Navigator.of(context).pop();
                            onClose?.call();
                          },
                        ),
                      ],
                    ),
                  ),
                  
                  const Divider(),
                  
                  // Broadcasts list
                  Expanded(
                    child: provider.broadcasts.isEmpty
                        ? const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  '📢',
                                  style: TextStyle(fontSize: 48),
                                ),
                                SizedBox(height: 16),
                                Text(
                                  'No announcements',
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            controller: scrollController,
                            padding: const EdgeInsets.only(top: 8, bottom: 24),
                            itemCount: provider.broadcasts.length,
                            itemBuilder: (context, index) {
                              final broadcast = provider.broadcasts[index];
                              return BroadcastCard(
                                broadcast: broadcast,
                                onView: () => provider.viewBroadcast(broadcast.id),
                                onAction: () {
                                  provider.onBroadcastAction(broadcast);
                                  Navigator.of(context).pop();
                                },
                                onDismiss: () => provider.dismissBroadcast(broadcast.id),
                              );
                            },
                          ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
