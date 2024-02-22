using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.RazorPages;
using Microsoft.Extensions.Options;

namespace Demo.Pages
{
    public class IndexModel : PageModel
    {
        public Settings Settings { get; }

        public IndexModel(IOptionsSnapshot<Settings> option)
        {
            Settings = option.Value;
        }
    }
}
