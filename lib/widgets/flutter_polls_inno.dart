library flutter_polls;

import 'package:flutter/material.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

class FlutterPollsInno extends StatefulWidget {
  const FlutterPollsInno({
    required this.pollId,
    this.hasVoted = false,
    this.isOwn = false,
    this.userVotedOptionId,
    required this.onVoted,
    this.loadingWidget,
    required this.pollTitle,
    this.heightBetweenTitleAndOptions = 10,
    required this.pollOptions,
    this.heightBetweenOptions,
    this.votesText = 'Votes',
    this.votesTextStyle,
    this.metaWidget,
    this.createdBy,
    this.userToVote,
    this.pollStartDate,
    this.pollEnded = false,
    this.pollOptionsHeight = 36,
    this.pollOptionsWidth,
    this.pollOptionsBorderRadius,
    this.pollOptionsFillColor,
    this.pollOptionsSplashColor = Colors.grey,
    this.pollOptionsBorder,
    this.votedPollOptionsRadius,
    this.votedBackgroundColor = const Color(0xffEEF0EB),
    this.votedProgressColor = const Color(0xff84D2F6),
    this.leadingVotedProgessColor = const Color(0xff0496FF),
    this.leadingVotedByUserProgessColor = const Color(0xff0496FF),
    this.votedCheckmark,
    this.votedPercentageTextStyle,
    this.votedAnimationDuration = 2000,
    required this.onPollOptionRemove,
  });

  /// The id of the poll.
  /// This id is used to identify the poll.
  /// It is also used to check if a user has already voted in this poll.
  final String? pollId;

  /// Checks if a user has already voted in this poll.
  /// If this is set to true, the user can't vote in this poll.
  /// Default value is false.
  /// [userVotedOptionId] must also be provided if this is set to true.
  final bool hasVoted;

  /// If a user has already voted in this poll.
  /// It is ignored if [hasVoted] is set to false or not set at all.
  final int? userVotedOptionId;

  /// An asynchronous callback for HTTP call feature
  /// Called when the user votes for an option.
  /// The index of the option that the user voted for is passed as an argument.
  /// If the user has already voted, this callback is not called.
  /// If the user has not voted, this callback is called.
  /// If the callback returns true, the tapped [PollOption] is considered as voted.
  /// Else Nothing happens,
  final Future<bool> Function(PollOption pollOption, int newTotalVotes) onVoted;

  /// The title of the poll. Can be any widget with a bounded size.
  final Widget pollTitle;

  /// Data format for the poll options.
  /// Must be a list of [PollOptionData] objects.
  /// The list must have at least two elements.
  /// The first element is the option that is selected by default.
  /// The second element is the option that is selected by default.
  /// The rest of the elements are the options that are available.
  /// The list can have any number of elements.
  ///
  /// Poll options are displayed in the order they are in the list.
  /// example:
  ///
  /// pollOptions = [
  ///
  ///  PollOption(id: 1, title: Text('Option 1'), votes: 2),
  ///
  ///  PollOption(id: 2, title: Text('Option 2'), votes: 5),
  ///
  ///  PollOption(id: 3, title: Text('Option 3'), votes: 9),
  ///
  ///  PollOption(id: 4, title: Text('Option 4'), votes: 2),
  ///
  /// ]
  ///
  /// The [id] of each poll option is used to identify the option when the user votes.
  /// The [title] of each poll option is displayed to the user.
  /// [title] can be any widget with a bounded size.
  /// The [votes] of each poll option is the number of votes that the option has received.
  final List<PollOption> pollOptions;

  /// The height between the title and the options.
  /// The default value is 10.
  final double? heightBetweenTitleAndOptions;

  /// The height between the options.
  /// The default value is 0.
  final double? heightBetweenOptions;

  /// Votes text. Can be "Votes", "Votos", "Ibo" or whatever language.
  /// If not specified, "Votes" is used.
  final String? votesText;

  /// [votesTextStyle] is the text style of the votes text.
  /// If not specified, the default text style is used.
  /// Styles for [totalVotes] and [votesTextStyle].
  final TextStyle? votesTextStyle;

  /// [metaWidget] is displayed at the bottom of the poll.
  /// It can be any widget with an unbounded size.
  /// If not specified, no meta widget is displayed.
  /// example:
  /// metaWidget = Text('Created by: $createdBy')
  final Widget? metaWidget;

  /// Who started the poll.
  final String? createdBy;

  /// Current user about to vote.
  final String? userToVote;

  /// The date the poll was created.
  final DateTime? pollStartDate;

  /// If poll is closed.
  final bool pollEnded;

  /// Height of a [PollOption].
  /// The height is the same for all options.
  /// Defaults to 36.
  final double? pollOptionsHeight;

  /// Width of a [PollOption].
  /// The width is the same for all options.
  /// If not specified, the width is set to the width of the poll.
  /// If the poll is not wide enough, the width is set to the width of the poll.
  /// If the poll is too wide, the width is set to the width of the poll.
  final double? pollOptionsWidth;

  /// Border radius of a [PollOption].
  /// The border radius is the same for all options.
  /// Defaults to 0.
  final BorderRadius? pollOptionsBorderRadius;

  /// Border of a [PollOption].
  /// The border is the same for all options.
  /// Defaults to null.
  /// If null, the border is not drawn.
  final BoxBorder? pollOptionsBorder;

  /// Color of a [PollOption].
  /// The color is the same for all options.
  /// Defaults to [Colors.blue].
  final Color? pollOptionsFillColor;

  /// Splashes a [PollOption] when the user taps it.
  /// Defaults to [Colors.grey].
  final Color? pollOptionsSplashColor;

  /// Radius of the border of a [PollOption] when the user has voted.
  /// Defaults to Radius.circular(8).
  final Radius? votedPollOptionsRadius;

  /// Color of the background of a [PollOption] when the user has voted.
  /// Defaults to [const Color(0xffEEF0EB)].
  final Color? votedBackgroundColor;

  /// Color of the progress bar of a [PollOption] when the user has voted.
  /// Defaults to [const Color(0xff84D2F6)].
  final Color? votedProgressColor;

  /// Color of the leading progress bar of a [PollOption] when the user has voted.
  /// Defaults to [const Color(0xff0496FF)].
  final Color? leadingVotedProgessColor;

  final Color? leadingVotedByUserProgessColor;

  /// Widget for the checkmark of a [PollOption] when the user has voted.
  /// Defaults to [Icons.check_circle_outline_rounded].
  final Widget? votedCheckmark;

  /// TextStyle of the percentage of a [PollOption] when the user has voted.
  final TextStyle? votedPercentageTextStyle;

  /// Animation duration of the progress bar of the [PollOption]'s when the user has voted.
  /// Defaults to 1000 milliseconds.
  /// If the animation duration is too short, the progress bar will not animate.
  /// If you don't want the progress bar to animate, set this to 0.
  final int votedAnimationDuration;

  /// Loading animation widget for [PollOption] when [onVoted] callback is invoked
  /// Defaults to [CircularProgressIndicator]
  /// Visible until the [onVoted] execution is completed,
  final Widget? loadingWidget;

  final Function onPollOptionRemove;

  final bool isOwn;

  @override
  State<FlutterPollsInno> createState() => _FlutterPollsInnoState();
}

// FlutterPolls widget.
// This widget is used to display a poll.
// It can be used in any way and also in a [ListView] or [Column].
class _FlutterPollsInnoState extends State<FlutterPollsInno> {
  bool _doAnimate = true;

  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    PollOption? votedOption = (widget.hasVoted == false ||
            widget.pollOptions
                .where(
                  (pollOption) => pollOption.id == widget.userVotedOptionId,
                )
                .isEmpty
        ? null
        : widget.pollOptions
            .where(
              (pollOption) => pollOption.id == widget.userVotedOptionId,
            )
            .toList()
            .first);
    final totalVotes =
        widget.pollOptions.map((e) => e.votes).reduce((a, b) => a + b);

    return Column(
      key: ValueKey(widget.pollId),
      children: [
        widget.pollTitle,
        SizedBox(height: widget.heightBetweenTitleAndOptions),
        if (widget.pollOptions.length < 2)
          throw ('>>>Flutter Polls: Poll must have at least 2 options.<<<')
        else
          ...widget.pollOptions.map(
            (pollOption) {
              return AnimatedSwitcher(
                duration: Duration(milliseconds: 300),
                child: widget.hasVoted
                    ? Container(
                        key: UniqueKey(),
                        margin: EdgeInsets.only(
                          bottom: widget.heightBetweenOptions ?? 8,
                        ),
                        child: InkWell(
                          onTap: () {
                            if(!widget.isOwn){
                              _onOptionTap(votedOption, pollOption, totalVotes);
                            }
                          },
                          child: LinearPercentIndicator(
                            width: MediaQuery.of(context).size.width - 22,
                            lineHeight: widget.pollOptionsHeight!,
                            barRadius: widget.votedPollOptionsRadius ??
                                const Radius.circular(8),
                            padding: EdgeInsets.zero,
                            onAnimationEnd: () => _doAnimate = false,
                            percent: totalVotes == 0
                                ? 0
                                : pollOption.votes / totalVotes,
                            animation: _doAnimate,
                            animationDuration: widget.votedAnimationDuration,
                            backgroundColor: widget.votedBackgroundColor,
                            progressColor: pollOption.votes ==
                                    widget.pollOptions
                                        .reduce(
                                          (max, option) =>
                                              max.votes > option.votes
                                                  ? max
                                                  : option,
                                        )
                                        .votes
                                ? (widget.userVotedOptionId != null &&
                                        widget.userVotedOptionId ==
                                            pollOption.id
                                    ? widget.leadingVotedByUserProgessColor
                                    : widget.leadingVotedProgessColor)
                                : widget.votedProgressColor,
                            center: Container(
                              width: MediaQuery.of(context).size.width - 10,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 5,
                              ),
                              child: Container(
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    pollOption.title,
                                    votedOption != null &&
                                            votedOption.id == pollOption.id
                                        ? const Icon(
                                            Icons.check_circle_outline_rounded,
                                            color: Colors.black,
                                            size: 16,
                                          )
                                        : Container(),
                                    Text(
                                      totalVotes == 0
                                          ? "0 ${widget.votesText}"
                                          : '${(pollOption.votes / totalVotes * 100).toStringAsFixed(1)}% (${pollOption.votes})',
                                      style: widget.votedPercentageTextStyle,
                                      textAlign: TextAlign.end,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      )
                    : Container(
                        key: UniqueKey(),
                        margin: EdgeInsets.only(
                          bottom: widget.heightBetweenOptions ?? 8,
                        ),
                        child: InkWell(
                          onTap: () {
                            _onOptionTap(votedOption, pollOption, totalVotes);
                          },
                          splashColor: widget.pollOptionsSplashColor,
                          borderRadius: widget.pollOptionsBorderRadius ??
                              BorderRadius.circular(
                                8,
                              ),
                          child: Container(
                            height: widget.pollOptionsHeight,
                            width: widget.pollOptionsWidth,
                            padding: EdgeInsets.zero,
                            decoration: BoxDecoration(
                              color: widget.pollOptionsFillColor,
                              border: widget.pollOptionsBorder ??
                                  Border.all(
                                    color: Colors.black,
                                    width: 1,
                                  ),
                              borderRadius: widget.pollOptionsBorderRadius ??
                                  BorderRadius.circular(
                                    8,
                                  ),
                            ),
                            child: Center(
                              child:
                                  isLoading && pollOption.id == votedOption!.id
                                      ? widget.loadingWidget ??
                                          const SizedBox(
                                            height: 20,
                                            width: 20,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                            ),
                                          )
                                      : pollOption.title,
                            ),
                          ),
                        ),
                      ),
              );
            },
          ),
      ],
    );
  }

  Future<void> _onOptionTap(
      PollOption? votedOption, PollOption pollOption, int totalVotes) async {
    // Disables clicking while loading
    if (isLoading) return;

    if (votedOption == pollOption) {
      widget.onPollOptionRemove();
    } else {
      votedOption = pollOption;

      isLoading = true;

      bool success = await widget.onVoted(
        votedOption,
        totalVotes,
      );

      isLoading = false;

      if (success) {
        _doAnimate = true;
        pollOption.votes++;
      }
    }
  }
}

class PollOption {
  PollOption({
    this.id,
    required this.title,
    required this.votes,
  });

  final int? id;
  final Widget title;
  int votes;
}
