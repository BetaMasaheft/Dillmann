/* Lists the Git history of a lemma from the DillmannData repository, with a
   permanent link to each version. Git is authoritative: only merged commits
   are listed, so a record not yet merged has no permalinks. Expects
   <div id="permanentIDs" data-id="L..." data-path="4/L....xml"> and a
   button #LoadPermanentIDs. */
$("#LoadPermanentIDs").on("click", function () {
  var button = $(this);
  var box = $("#permanentIDs");
  var id = box.data("id");
  var path = box.data("path");
  var repo = "BetaMasaheft/DillmannData";
  var api = "https://api.github.com/repos/" + repo + "/commits?per_page=100&path=" + encodeURIComponent(path);

  function row(label, href) {
    var tr = $("<tr></tr>");
    tr.append($("<td></td>").text(label));
    tr.append($("<td></td>").append($("<a></a>").attr("href", href).text(href)));
    return tr;
  }

  $.getJSON(api)
    .done(function (commits) {
      button.remove();
      if (!commits.length) {
        box.append(
          $("<p></p>").text(
            "This lemma has not been merged into the DillmannData repository yet, so no permanent versions exist.",
          ),
        );
        return;
      }
      $.each(commits, function (_, c) {
        var sha = c.sha;
        var table = $("<table class='w3-table w3-bordered'></table>");
        table.append(
          $("<tr></tr>")
            .append($("<th></th>").text("Version of " + c.commit.committer.date))
            .append(
              $("<th></th>").text(
                "SHA: " +
                  sha +
                  " committed to GitHub by " +
                  c.commit.author.name +
                  " with the following message: " +
                  c.commit.message,
              ),
            ),
        );
        table.append(row("permalink to this version", location.origin + "/Dillmann/permanent/" + sha + "/" + id));
        table.append(
          row("source file at this version", "https://raw.githubusercontent.com/" + repo + "/" + sha + "/" + path),
        );
        table.append(
          row("source file in GitHub at this version", "https://github.com/" + repo + "/blob/" + sha + "/" + path),
        );
        box.append(table);
      });
    })
    .fail(function () {
      box.append($("<p></p>").text("The revision history could not be loaded from GitHub."));
    });
});
