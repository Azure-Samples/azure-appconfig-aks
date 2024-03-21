using Microsoft.AspNetCore.Mvc.RazorPages;
using Microsoft.Extensions.Options;
using Microsoft.FeatureManagement.Mvc;

namespace Demo.Pages
{
    [FeatureGate("Beta")]
    public class BetaModel : PageModel
    {
        public Settings Settings { get; }

        public BetaModel(IOptionsSnapshot<Settings> option)
        {
            Settings = option.Value;
        }
    }
}
